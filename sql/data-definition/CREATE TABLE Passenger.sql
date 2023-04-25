CREATE TABLE Passenger (
    PassengerID INTEGER NOT NULL,
    FirstName VARCHAR(20) NOT NULL,
    Surname VARCHAR(40) NOT NULL,
    PassportNo VARCHAR(30) NOT NULL,
    Nationality VARCHAR(30) NOT NULL,
    Dob DATE NOT NULL
        CHECK (Dob > CURRENT_TIMESTAMP),
    PRIMARY KEY(PassengerID)
);