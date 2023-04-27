CREATE PROCEDURE InsertFlightBooking(
    IN BookingID INTEGER,
    IN CustomerID INTEGER,
    IN FlightID INTEGER,
    IN NumSeats INTEGER,
    IN TotalCost DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create booking
    INSERT INTO FlightBooking (bookingid,
                               customerid,
                               flightid,
                               numseats,
                               totalcost)
    VALUES (BookingID,
            CustomerID,
            FlightID,
            NumSeats,
            TotalCost);
END;
$$;

