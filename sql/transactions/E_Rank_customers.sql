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