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
