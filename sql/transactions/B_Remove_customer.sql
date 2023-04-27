-- B. Given a customer ID number, remove the record for that customer. It should
-- not be possible to remove customers that have active (i.e., reserved) flight
-- bookings. A customer that has only cancelled bookings could be removed; the
-- associated bookings should also be removed along with all the seat bookings.

CREATE PROCEDURE InsertFlightBooking
    @CustomerID INTEGER,
    @FlightID INTEGER,
    @NumSeats INTEGER
