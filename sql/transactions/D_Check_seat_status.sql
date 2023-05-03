-- D. Given a flight ID number, check the status of all seats currently allocated to
-- that flight, i.e., return the total number of reserved/ cancelled/ available seat.

SELECT COUNT(Status) FILTER (WHERE Status = 'R') AS TotalReserved,
       COUNT(Status) FILTER (WHERE Status = 'C') AS TotalCancelled,
       GetFlightSeatAvailability(1)              AS TotalAvailable
FROM SeatBooking
         JOIN FlightBooking
              ON SeatBooking.BookingID = FlightBooking.BookingID;