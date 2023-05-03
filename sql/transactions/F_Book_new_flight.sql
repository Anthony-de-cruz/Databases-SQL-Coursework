-- F. Given a booking ID, customer ID number, flight ID number, number of seats
-- required and passenger details, make a booking for a given flight. This procedure
-- should first show seats available in a given flight and then proceed to insert
-- booking, if there are sufficient seats available. The customer could be an existing
-- customer or a new customer, in which case it should be entered first into the
-- database. Seats numbers can be allocated at the time of booking or later on.
-- The making of a booking with all the steps outlined should work as an atomic
-- operation.

CALL BookFlight(
        222,
        700,
        2,
        3,
        ARRAY [1919,
            2020, 2011]:: INTEGER[],
        ARRAY ['20A',
            '20B', '20C'],
        ROW (700,
            'Jonas',
            'Jones',
            '123 Big Rd',
            'JJBIG@example.com')::LeadCustomer,
        ARRAY [
            ROW (1919,
                'Bob',
                'Dob',
                'pass1231',
                'Mars',
                '1904-01-01')::passenger,
            ROW (2020,
                'Bobbin',
                'Smithz',
                'pssport123',
                'yes',
                '1920-01-01')::passenger,
            ROW (2011,
                'Cheese',
                'Grilllz',
                'pssport123123',
                'Saturn',
                '1999-01-01')::passenger
            ]);