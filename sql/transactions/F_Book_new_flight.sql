-- F. Given a booking ID, customer ID number, flight ID number, number of seats
-- required and passenger details, make a booking for a given flight. This procedure
-- should first show seats available in a given flight and then proceed to insert
-- booking, if there are sufficient seats available. The customer could be an existing
-- customer or a new customer, in which case it should be entered first into the
-- database. Seats numbers can be allocated at the time of booking or later on.
-- The making of a booking with all the steps outlined should work as an atomic
-- operation.

-- BEGIN TRANSACTION;
-- EXECUTE BookFlight(123, 50, 1, 2, [1, 2]);
-- COMMIT;