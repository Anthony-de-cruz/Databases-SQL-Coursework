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
VALUES (123, 'Bob', 'Bobbington','1 Bob Street', 'bob@bob.com');

-- b
INSERT INTO Passenger (
                       passengerid,
                       firstname,
                       surname,
                       passportno,
                       nationality,
                       dob)
VALUES (5, 'Jim', 'Jimming', 'weee123', 'dog', '01-02-2000');

-- c
INSERT INTO Flight (flightid,
                    flightdate,
                    origin,
                    destination,
                    maxcapacity,
                    priceperseat)
VALUES (200, CURRENT_TIMESTAMP, 'bed', 'car', 200, 60)
