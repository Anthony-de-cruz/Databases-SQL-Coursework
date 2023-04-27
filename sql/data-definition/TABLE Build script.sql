-- BUILD/REBUILD SCRIPT

DROP TABLE IF EXISTS SeatBooking;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS FlightBooking;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS LeadCustomer;

-------------------------- Create Tables -------------------------

CREATE Table LeadCustomer
(
    CustomerId     INTEGER      NOT NULL,
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
        CHECK (BookingTime >= CURRENT_TIMESTAMP)
        DEFAULT CURRENT_TIMESTAMP,
    TotalCost   DECIMAL
        CHECK (0 < TotalCost),
    PRIMARY KEY (BookingID),
    FOREIGN KEY (CustomerID) REFERENCES leadcustomer (CustomerID)
        ON DELETE RESTRICT
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

CREATE OR REPLACE FUNCTION UpdateFlightBookingCost()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE FlightBooking
    SET TotalCost = NEW.NumSeats * Flight.PricePerSeat
    FROM Flight
    WHERE FlightBooking.FlightID = Flight.FlightID
      AND FlightBooking.BookingID = NEW.BookingID;

    RETURN NEW;
END;
$$;

------------------------- Create Triggers ------------------------

CREATE TRIGGER UpdateFlightBookingCostTrigger
    AFTER INSERT OR UPDATE
    ON FlightBooking
    FOR EACH ROW
EXECUTE FUNCTION UpdateFlightBookingCost();
