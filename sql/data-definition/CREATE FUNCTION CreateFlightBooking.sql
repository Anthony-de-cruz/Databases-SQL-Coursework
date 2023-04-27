CREATE FUNCTION CreateFlightBooking(
    IN BookingID INTEGER,
    IN FlightID INTEGER,
    IN NumSeats INTEGER
)
    RETURNS DECIMAL
    LANGUAGE plpgsql
AS
$$
DECLARE
TotalCost
    BEGIN
END;
$$

-- CREATE OR REPLACE FUNCTION CalcualteTripCost(
--     IN inp_FlightID INTEGER,
--     IN inp_NumSeats INTEGER
-- )
-- RETURNS DECIMAL
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN (inp_NumSeats * (
--         SELECT PricePerSeat FROM Flight WHERE Flight.FlightID = inp_FlightID));
-- END;
-- $$

-- IN BookingID INTEGER,
--     IN CustomerID INTEGER,
--     IN FlightID INTEGER,
--     IN NumSeats INTEGER,
--     IN TotalCost DECIMAL