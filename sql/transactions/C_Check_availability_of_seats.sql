SELECT FlightID,
       FlightDate,
       (SELECT SUM(NumSeats) AS BookedSeats
        FROM FlightBooking
        WHERE FlightBooking.FlightID = Flight.FlightID
          AND Status = 'R'),
       GetFlightSeatAvailability(FlightID) AS AvailableSeats,
       MaxCapacity
FROM Flight;


-- (SELECT SUM(NumSeats) AS BookedSeats
-- FROM FlightBooking
-- WHERE FlightID = 1
--   AND Status = 'R')