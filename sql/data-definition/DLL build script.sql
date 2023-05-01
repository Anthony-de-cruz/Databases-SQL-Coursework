-- !PLpgSQL
-- BUILD/REBUILD SCRIPT

DROP TABLE IF EXISTS SeatBooking;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS FlightBooking;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS LeadCustomer;

-------------------------- Create Tables -------------------------

CREATE Table LeadCustomer
(
    CustomerID     INTEGER      NOT NULL,
    FirstName      VARCHAR(20)  NOT NULL,
    Surname        VARCHAR(40)  NOT NULL,
    BillingAddress VARCHAR(200) NOT NULL,
    email          VARCHAR(30)  NOT NULL,
    PRIMARY KEY (CustomerID)
);

CREATE TABLE Passenger
(
    PassengerID INTEGER     NOT NULL,
    FirstName   VARCHAR(20) NOT NULL,
    Surname     VARCHAR(40) NOT NULL,
    PassportNo  VARCHAR(30) NOT NULL,
    Nationality VARCHAR(30) NOT NULL,
    Dob         DATE        NOT NULL
        CHECK (Dob < CURRENT_TIMESTAMP),
    PRIMARY KEY (PassengerID)
);

CREATE TABLE Flight
(
    FlightID     INTEGER     NOT NULL,
    FlightDate   TIMESTAMP   NOT NULL,
    Origin       VARCHAR(30) NOT NULL,
    Destination  VARCHAR(30) NOT NULL,
    MaxCapacity  INTEGER     NOT NULL
        CHECK (0 < MaxCapacity),
    PricePerSeat DECIMAL     NOT NULL
        CHECK (0 < PricePerSeat),
    PRIMARY KEY (FlightID)
);

CREATE TABLE FlightBooking
(
    BookingID   INTEGER   NOT NULL,
    CustomerID  INTEGER   NOT NULL,
    FlightID    INTEGER   NOT NULL,
    NumSeats    INTEGER   NOT NULL
        CHECK (0 < NumSeats),
    Status      CHAR(1)   NOT NULL
        CHECK (Status = 'R' OR Status = 'C')
        DEFAULT 'R',
    BookingTime TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,
    TotalCost   DECIMAL
        CHECK (0 < TotalCost)
        DEFAULT NULL,
    PRIMARY KEY (BookingID),
    FOREIGN KEY (CustomerID) REFERENCES leadcustomer (CustomerID)
        ON DELETE CASCADE -- In the event that the operation is not
        -- stopped by RestrictCustomerDeletionTrigger
        ON UPDATE RESTRICT,
    FOREIGN KEY (FlightID) REFERENCES flight (FlightID)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

CREATE TABLE SeatBooking
(
    BookingID   INTEGER NOT NULL,
    PassengerID INTEGER NOT NULL,
    SeatNumber  CHAR(4) NOT NULL,
    PRIMARY KEY (BookingID, PassengerID),
    UNIQUE (SeatNumber),
    FOREIGN KEY (BookingID) REFERENCES FlightBooking (BookingID)
        ON DELETE CASCADE,
    FOREIGN KEY (PassengerID) REFERENCES Passenger (PassengerID)
        ON DELETE RESTRICT
);

------------------------- Create Routines ------------------------

CREATE OR REPLACE FUNCTION GetFlightSeatAvailability(
    -- Returns the number of seats available.
    IN CheckFlightID INTEGER
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    Capacity    INTEGER := (SELECT MaxCapacity
                            FROM Flight
                            WHERE CheckFlightID = Flight.FlightID);
    BookedSeats INTEGER := (SELECT SUM(NumSeats)
                            FROM FlightBooking
                            WHERE CheckFlightID = FlightBooking.FlightID
                              AND FlightBooking.Status != 'C');
BEGIN
    IF (BookedSeats IS NULL)
    THEN
        --RAISE EXCEPTION 'Flight does not exist.';
        RETURN Capacity;
    END IF;

    IF (Capacity - BookedSeats < 0)
    THEN
        RETURN 0;
    END IF;

    RETURN Capacity - BookedSeats;
END;
$$;


------------------------- Create Triggers ------------------------

CREATE OR REPLACE FUNCTION UpdateFlightBookingCost()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN

    NEW.TotalCost = NEW.NumSeats * (SELECT PricePerSeat
                                    FROM Flight
                                    WHERE NEW.FlightID = Flight.FlightID);
    RETURN NEW;
END;
$$;

CREATE TRIGGER UpdateFlightBookingCost
    BEFORE INSERT OR UPDATE
    ON FlightBooking
    FOR EACH ROW
EXECUTE FUNCTION UpdateFlightBookingCost();

CREATE OR REPLACE FUNCTION CheckFlightCapacity()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF (GetFlightSeatAvailability(NEW.FlightID) - NEW.NumSeats > 0) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'The flight is fully booked.';
END;
$$;

CREATE TRIGGER EnforceMaxCapacity
    BEFORE INSERT OR UPDATE
    ON FlightBooking
    FOR EACH ROW
EXECUTE FUNCTION CheckFlightCapacity();

CREATE OR REPLACE FUNCTION RestrictCustomerDeletion()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF EXISTS (SELECT 1
               FROM FlightBooking
               WHERE OLD.CustomerID = FlightBooking.CustomerID
                 AND FlightBooking.Status = 'R') THEN
        RAISE EXCEPTION 'Cannot delete a customer that has a reserved booking.';
    END IF;
    RETURN OLD;
END;
$$;

CREATE TRIGGER RestrictCustomerDeletionTrigger
    BEFORE DELETE
    ON LeadCustomer
    FOR EACH ROW
EXECUTE FUNCTION RestrictCustomerDeletion();