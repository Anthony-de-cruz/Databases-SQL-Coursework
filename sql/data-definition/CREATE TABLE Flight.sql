CREATE TABLE Flight (
    FlightID INTEGER NOT NULL,
    FlightDate TIMESTAMP NOT NULL,
    Origin VARCHAR(30) NOT NULL,
    Destination VARCHAR(30) NOT NULL,
    MaxCapacity INTEGER NOT NULL
        CHECK (0 < MaxCapacity),
    PricePerSeat DECIMAL NOT NULL
        CHECK (0 < PricePerSeat),
    PRIMARY KEY(FlightID)
);