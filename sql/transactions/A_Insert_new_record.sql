-- A. Insert a new record. This could be
    -- a. Given a lead customer ID number, name, and contact details, create a
    -- new customer record.
    -- b. Given a passenger with an ID, name, date of birth, etc., create a new
    -- passenger record.
    -- c. Given a flight ID number, origin, destination, flight date, capacity of the
    -- aircraft, and price per seat create a new flight record.
-- a
INSERT INTO LeadCustomer (
                          customerid,
                          firstname,
                          surname,
                          billingaddress,
                          email)
VALUES (999, 'Bob', 'Bobbington','1 Bob Street', 'bob@bob.com');

-- b
INSERT INTO Passenger (
                       passengerid,
                       firstname,
                       surname,
                       passportno,
                       nationality,
                       dob)
VALUES (999, 'Jim', 'Jimming', 'pssprtno998', 'man', '01-02-2000');

-- c
INSERT INTO Flight(FlightID,
                   FlightDate,
                   Origin,
                   Destination,
                   MaxCapacity,
                   PricePerSeat)
VALUES (999, '01-01-2024 09:02', 'Place1', 'Place2', 200, 300)
