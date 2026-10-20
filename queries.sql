-- Find all bookings given renter first name and last name
SELECT * FROM "bookings"
WHERE "renter_id" IN (
    SELECT "id"
    FROM "renters"
    WHERE "first_name" = 'Sarah'
    AND "last_name" = 's.collings@example.com'
);


-- Find all properties given name and email address
SELECT * FROM "properties"
WHERE "owner_id" IN (
    SELECT "id"
    FROM "company_owners"
    WHERE "name" = 'Holiday Rentals'
    AND "email" = 'holiday_rentals@example.com'
UNION
    SELECT "id"
    FROM "private_owners"
    WHERE "name" = 'Holiday Rentals'
    AND "email" = 'holiday_rentals@example.com'
);


-- Find all booking changes given time and booking id
SELECT * FROM booking_events
WHERE "created_at" > '2026-08-01'
AND "booking_id" = 1;


-- Inserting an owner requires two table entries at once
BEGIN TRANSACTION;
INSERT INTO owners ("type")
VALUES ('private');
INSERT INTO "private_owners"
    ("id", "first_name", "last_name", "email", "password")
VALUES
    (
        last_insert_rowid(),
        'John',
        'Smith',
        'john@example.com',
        '3b842bcd6faab4047ab49f9a99fa0704b9c9d2d7'
    );
COMMIT;

BEGIN TRANSACTION;
INSERT INTO owners ("type")
VALUES ('company');
INSERT INTO "company_owners"
    ("id", "name", "company_reg_id", "email", "password")
VALUES
    (
        last_insert_rowid(),
        'Holiday Rentals',
        '123abc231cba',
        'holiday_rentals@example.com',
        '90334def66d94274f49f9216087fe71d41ded9b4'
    );
COMMIT;


-- Adding a new renter
INSERT INTO "renters" ("first_name", "last_name", "email", "password")
VALUES
('Sarah', 'Collings', 's.collings@example.com', '67056c23af2a3fa6bd9c28953fd6ba0411375259');


-- Adding a new property
INSERT INTO properties ("name", "type", "owner_id", "location_id", "bedrooms", "sleeps", "bathrooms", "wc", "living_rooms", "dining_rooms", "property_description", "currency", "active")
VALUES
('Blue Rose Villa', 'villa', 1, 1, 3, 6, 2, 0, 1, 1, 'Cool villa somewhere in Spain.', 'USD', 1),


-- Adding amenities
INSERT INTO "amenities" ("name")
VALUES
('private pool'),
('garden'),
('game room'),
('parking');


-- Adding locations
INSERT INTO "locations" ("country","region", "province", "city")
VALUES ('Spain', 'Costa del Sol', 'Malaga Province', 'Malaga');
