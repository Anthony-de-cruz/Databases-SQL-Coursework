-- !PLpgSQL
-- BUILD/REBUILD SCRIPT

DROP PROCEDURE IF EXISTS BookFlight;
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
    FOREIGN KEY (BookingID) REFERENCES FlightBooking (BookingID)
        ON DELETE CASCADE,
    FOREIGN KEY (PassengerID) REFERENCES Passenger (PassengerID)
        ON DELETE RESTRICT
);

------------------------- Create Routines ------------------------

CREATE OR REPLACE PROCEDURE BookFlight(
    IN newBookingID INTEGER,
    IN newCustomerID INTEGER,
    IN newFlightID INTEGER,
    IN newNumSeats INTEGER,
    IN PassengerIDs INTEGER[],
    IN SeatNums CHAR(4)[],
    IN newCustomer LeadCustomer DEFAULT NULL,
    IN newPassengers Passenger[] DEFAULT NULL
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    newPassenger Passenger;
    num          CHAR(4);
BEGIN
    -- Check to see if the passenger num is correct
    IF cardinality(PassengerIDs) > cardinality(SeatNums) THEN
        RAISE EXCEPTION 'Cannot have more passengers than number of seats';
    END IF;

    -- Create customer
    IF newCustomer IS NOT NULL THEN
        RAISE NOTICE 'THIS IS BEING MADE';
        INSERT INTO LeadCustomer
        VALUES (newCustomer.CustomerID,
                newCustomer.Firstname,
                newCustomer.Surname,
                newCustomer.BillingAddress,
                newCustomer.email);
    END IF;

    -- Create booking
    INSERT INTO FlightBooking
    VALUES (newBookingID, newCustomerID, newFlightID, newNumSeats);

    -- Create new passengers
    FOREACH newPassenger IN ARRAY newPassengers
        LOOP
            raise notice '%', newPassenger;
            INSERT INTO Passenger
            VALUES (newPassenger.PassengerID,
                    newPassenger.FirstName,
                    newPassenger.Surname,
                    newPassenger.PassportNo,
                    newPassenger.Nationality,
                    newPassenger.Dob);
        END LOOP;

    -- Assign passenger seats
    FOR i IN array_lower(SeatNums, 1)..array_upper(SeatNums, 1)
        LOOP
            RAISE NOTICE '%, %, %', newBookingID, PassengerIDs[i], i;
            INSERT INTO SeatBooking
            VALUES (newBookingID, PassengerIDs[i], SeatNums[i]);
        END LOOP;
END;
$$;

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

-- Exists to keep the flight booking total costs
-- up to date (such as when you add a new passenger).
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

-- Exists to throw exception if there aren't enough seats.
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

-- Exists to throw exception when
-- deleting a customer with a reserved booking.
CREATE TRIGGER RestrictCustomerDeletionTrigger
    BEFORE DELETE
    ON LeadCustomer
    FOR EACH ROW
EXECUTE FUNCTION RestrictCustomerDeletion();

CREATE OR REPLACE FUNCTION RestrictSeatBooking()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE

BEGIN
    -- Check to see if the flight booking exists.
    IF NOT EXISTS(SELECT 1
                  FROM FlightBooking
                  WHERE FlightBooking.BookingID = NEW.BookingID) THEN
        RAISE EXCEPTION 'Cannot allocate seat for a booking that does not exist.';
    END IF;
    -- Check to see if the booking is not cancelled.
    IF (SELECT Status
        FROM FlightBooking
        WHERE FlightBooking.BookingID = NEW.BookingID) = 'C' THEN
        RAISE EXCEPTION 'Cannot allocate seat for a booking that is cancelled.';
    END IF;
    -- Check to see if there are seats left for the booking.
    IF ((SELECT NumSeats
         FROM FlightBooking
         WHERE BookingID = NEW.BookingID) - (SELECT COUNT(BookingID)
                                             FROM SeatBooking
                                             WHERE BookingID = NEW.BookingID)
           ) <= 0 THEN
        RAISE EXCEPTION 'Cannot book seat as there are none available for this booking.';
    END IF;
    -- Check to see if the seat is taken.
    IF EXISTS (SELECT
               FROM SeatBooking
                        JOIN FlightBooking
                             ON SeatNumber = NEW.Seatnumber AND
                                FlightBooking.Status = 'R') THEN
        RAISE EXCEPTION 'Seat is already taken.';
    END IF;

    RETURN NEW;
END;
$$;

-- Exists to throw exception when:
-- 1. If the flight booking exists.
-- 2. Check to see if the booking is not cancelled.
-- 3. Check to see if there are seats left for the booking.
-- 4. Check to see if the seat is taken.
CREATE TRIGGER RestrictSeatBookingTrigger
    BEFORE INSERT OR UPDATE
    ON SeatBooking
    FOR EACH ROW
EXECUTE FUNCTION RestrictSeatBooking();