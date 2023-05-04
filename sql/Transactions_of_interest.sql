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
VALUES (999, '01-01-2024 09:02', 'Place1', 'Place2', 150, 300)


-- B. Given a customer ID number, remove the record for that customer. It should
-- not be possible to remove customers that have active (i.e., reserved) flight
-- bookings. A customer that has only cancelled bookings could be removed; the
-- associated bookings should also be removed along with all the seat bookings.

INSERT INTO LeadCustomer(CustomerID,
                         FirstName,
                         Surname,
                         BillingAddress,
                         Email)
VALUES (998, 'To', 'Be', 'Deleted.Rd', 'whoops@okay.com');

DELETE FROM LeadCustomer WHERE (CustomerID = 988);


-- C. Check the availability of seats on all flights by showing the flight ID number,
-- flight date along with the number of booked seats, number of available seats and
-- maximum capacity.

SELECT FlightID,
       FlightDate,
       (SELECT SUM(NumSeats) AS BookedSeats
        FROM FlightBooking
        WHERE FlightBooking.FlightID = Flight.FlightID
          AND Status = 'R'),
       GetFlightSeatAvailability(FlightID) AS AvailableSeats,
       MaxCapacity
FROM Flight;


-- D. Given a flight ID number, check the status of all seats currently allocated to
-- that flight, i.e., return the total number of reserved/ cancelled/ available seat.

SELECT COUNT(Status) FILTER (WHERE Status = 'R') AS TotalReserved,
       COUNT(Status) FILTER (WHERE Status = 'C') AS TotalCancelled,
       GetFlightSeatAvailability(1)              AS TotalAvailable
FROM SeatBooking
         JOIN FlightBooking
              ON SeatBooking.BookingID = FlightBooking.BookingID;


-- E. Produce a ranked list of all lead customers, showing their ID, their full name,
-- the total number of bookings made, and the total spend made for all bookings.
-- The list should be sorted by decreasing total value.

SELECT LeadCustomer.CustomerID,
       FirstName || Surname AS FullName,
       TotalBooking,
       TotalSpend
FROM LeadCustomer
         JOIN (SELECT CustomerID,
                      COUNT(BookingID) AS TotalBooking,
                      SUM(TotalCost)   AS TotalSpend
               FROM FlightBooking
               WHERE Status = 'R'
               GROUP BY CustomerID) AS Bookings
              ON LeadCustomer.CustomerID = Bookings.CustomerID
ORDER BY TotalSpend;


-- F. Given a booking ID, customer ID number, flight ID number, number of seats
-- required and passenger details, make a booking for a given flight. This procedure
-- should first show seats available in a given flight and then proceed to insert
-- booking, if there are sufficient seats available. The customer could be an existing
-- customer or a new customer, in which case it should be entered first into the
-- database. Seats numbers can be allocated at the time of booking or later on.
-- The making of a booking with all the steps outlined should work as an atomic
-- operation.

CALL BookFlight(
        222,
        700,
        2,
        3,
        ARRAY [1919,
            2020, 2011]:: INTEGER[],
        ARRAY ['20A',
            '20B', '20C'],
        ROW (700,
            'Jonas',
            'Jones',
            '123 Big Rd',
            'JJBIG@example.com')::LeadCustomer,
        ARRAY [
            ROW (1919,
                'Bob',
                'Dob',
                'pass1231',
                'Mars',
                '1904-01-01')::passenger,
            ROW (2020,
                'Bobbin',
                'Smithz',
                'pssport123',
                'yes',
                '1920-01-01')::passenger,
            ROW (2011,
                'Cheese',
                'Grilllz',
                'pssport123123',
                'Saturn',
                '1999-01-01')::passenger
            ]);


-- G. Given a booking ID number, cancel the booking. Note that cancelling a
-- booking only changes the status and should not delete the historical details of the
-- original booking. However, cancelled seats should be viewed as available.

UPDATE FlightBooking
SET Status = 'C'
WHERE bookingid = 222;