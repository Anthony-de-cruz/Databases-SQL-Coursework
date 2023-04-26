CREATE TABLE SeatBooking (
    BookingID INTEGER NOT NULL,
    PassengerID INTEGER NOT NULL,
    SeatNumber CHAR(4) NOT NULL,
    PRIMARY KEY (BookingID),
    UNIQUE (SeatNumber),
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID)
        ON DELETE RESTRICT
);