CREATE TABLE FlightBooking (
    BookingID INTEGER NOT NULL,
    CustomerID INTEGER NOT NULL,
    FlightID INTEGER NOT NULL,
    NumSeats INTEGER NOT NULL
        CHECK (0 < NumSeats),
    Status CHAR(1) NOT NULL,
    BookingTime TIMESTAMP NOT NULL
        CHECK (BookingTime >= CURRENT_TIMESTAMP)
        DEFAULT CURRENT_TIMESTAMP,
    TotalCost DECIMAL
        CHECK (0 < TotalCost),
    PRIMARY KEY (BookingID),
    FOREIGN KEY (CustomerID) REFERENCES leadcustomer(customerid)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    FOREIGN KEY (FlightID) REFERENCES flight(flightid)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);