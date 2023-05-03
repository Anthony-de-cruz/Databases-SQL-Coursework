-- G. Given a booking ID number, cancel the booking. Note that cancelling a
-- booking only changes the status and should not delete the historical details of the
-- original booking. However, cancelled seats should be viewed as available.

UPDATE FlightBooking
SET Status = 'C'
WHERE bookingid = 222;