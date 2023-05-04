-- Clear all tables.
TRUNCATE Seatbooking CASCADE;
TRUNCATE Passenger CASCADE;
TRUNCATE FlightBooking CASCADE;
TRUNCATE Flight CASCADE;
TRUNCATE LeadCustomer CASCADE;

-- Test to see if records can be entered into the database
INSERT INTO LeadCustomer (customerid,
                          firstname,
                          surname,
                          billingaddress,
                          email)
VALUES (1, 'Bob', 'Bobbington', '1 Bob Street', 'bob@bob.com');

INSERT INTO LeadCustomer (customerid,
                          firstname,
                          surname,
                          billingaddress,
                          email)
VALUES (2, 'Firstname', 'Surname', '2 Bob Street', 'REEEE@bob.com');

INSERT INTO LeadCustomer (customerid,
                          firstname,
                          surname,
                          billingaddress,
                          email)
VALUES (3, 'I am', 'to be', 'deleted', 'with@no.reservation');

INSERT INTO LeadCustomer (customerid,
                          firstname,
                          surname,
                          billingaddress,
                          email)
VALUES (4, 'I am', 'to be', 'deleted', 'with@cancelled.reservation');

INSERT INTO Passenger (passengerid,
                       firstname,
                       surname,
                       passportno,
                       nationality,
                       dob)
VALUES (1, 'Don', 'Zibsz', 'pssprtno0', 'mane', '01-02-2001');

INSERT INTO Passenger (passengerid,
                       firstname,
                       surname,
                       passportno,
                       nationality,
                       dob)
VALUES (2, 'Jim', 'Jimming', 'pssprtno998', 'man', '01-02-2000');

INSERT INTO Flight(FlightID,
                   FlightDate,
                   Origin,
                   Destination,
                   MaxCapacity,
                   PricePerSeat)
VALUES (1, '01-01-2044 09:02', 'Place1555', 'Place2', 220, 355);

INSERT INTO Flight(FlightID,
                   FlightDate,
                   Origin,
                   Destination,
                   MaxCapacity,
                   PricePerSeat)
VALUES (2, '01-01-2044 09:02', 'Smol', 'Plane', 200, 8);

INSERT INTO FlightBooking(BookingID,
                          CustomerID,
                          FlightID,
                          NumSeats)
VALUES (1, 1, 1, 4);

INSERT INTO FlightBooking(BookingID,
                          CustomerID,
                          FlightID,
                          NumSeats)
VALUES (2, 2, 2, 4);


INSERT INTO FlightBooking(BookingID,
                          CustomerID,
                          FlightID,
                          NumSeats)
VALUES (3, 2, 2, 3);

INSERT INTO FlightBooking(BookingID,
                          CustomerID,
                          FlightID,
                          NumSeats)
VALUES (4, 4, 1, 3);

INSERT INTO FlightBooking(BookingID,
                          CustomerID,
                          FlightID,
                          NumSeats)
VALUES (5, 2, 1, 2);

UPDATE FlightBooking
SET Status = 'C'
WHERE BookingID = 5;

-- Test the deletion of customers
DELETE
FROM LeadCustomer
WHERE CustomerID = 3;

UPDATE FlightBooking
SET Status = 'C'
WHERE BookingID = 4;

DELETE
FROM LeadCustomer
WHERE CustomerID = 4;

INSERT INTO SeatBooking (Bookingid,
                         PassengerID,
                         SeatNumber)
VALUES (1, 1, '1');

CALL BookFlight(
        1144,
        1,
        1,
        2,
        ARRAY [1001,
            1000]:: INTEGER[],
        ARRAY ['1a69',
            '11a'],
        ROW (111,
            'John',
            'Doe',
            '123 Main St',
            'johndoe@example.com')::LeadCustomer,
        ARRAY [
            ROW (1000,
                'Jane',
                'Doe',
                'passport1',
                'world',
                '1900-01-01')::passenger,
            ROW (1001,
                'Bob',
                'Smith',
                'pssport123',
                'yes',
                '1900-01-01')::passenger
            ]);


