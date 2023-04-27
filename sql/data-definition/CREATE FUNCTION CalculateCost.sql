CREATE OR REPLACE FUNCTION CalcualteTripCost(
    IN inp_FlightID INTEGER,
    IN inp_NumSeats INTEGER
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (inp_NumSeats * (
        SELECT PricePerSeat FROM Flight WHERE Flight.FlightID = inp_FlightID));
END;
$$
