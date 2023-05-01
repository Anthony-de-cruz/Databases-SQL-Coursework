-- B. Given a customer ID number, remove the record for that customer. It should
-- not be possible to remove customers that have active (i.e., reserved) flight
-- bookings. A customer that has only cancelled bookings could be removed; the
-- associated bookings should also be removed along with all the seat bookings.

INSERT INTO LeadCustomer(CustomerID,
                         FirstName,
                         Surname,
                         BillingAddress,
                         Email)
VALUES (998, 'To', 'Be', 'Deleted.Rd', 'whoops@okay.com');

DELETE FROM LeadCustomer WHERE (CustomerID = 988);