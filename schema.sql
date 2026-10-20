-- ############################################################### TABLES ###############################################################
-- ######################################################################################################################################

-- ############################ USERS ############################

-- Represents the type of property owners
CREATE TABLE "owners" (
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN ('private', 'company')),
    PRIMARY KEY ("id")
);


-- Represents private owner accounts
CREATE TABLE "private_owners" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("id") REFERENCES "owners"("id")
);


-- Represents company owner accounts
CREATE TABLE "company_owners" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "company_reg_id" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("id") REFERENCES "owners"("id")
);


-- Represents renter accounts
CREATE TABLE "renters" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL,
    PRIMARY KEY ("id")
);

-- ############################ USERS ############################


-- ########################### RENTALS ###########################

-- Represents rentals listed on the website with some most common info
CREATE TABLE "properties" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "type" TEXT  NOT NULL CHECK("type" IN('house', 'villa', 'apartment', 'bungalow', 'cottage', 'gite')), -- More house types should be added in production, depending on demand.
    "owner_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "bedrooms" INTEGER NOT NULL DEFAULT 0 CHECK("bedrooms" >= 0),
    "sleeps" INTEGER NOT NULL DEFAULT 0 CHECK("sleeps" >= 0), -- The number of people a house can sleep because the number of bedrooms does not determine how many people can sleep there.
    "bathrooms" INTEGER NOT NULL DEFAULT 0 CHECK("bathrooms" >= 0),
    "wc" INTEGER NOT NULL DEFAULT 0 CHECK("wc" >= 0), -- The number of toilet rooms without a bath or shower.
    "living_rooms" INTEGER NOT NULL DEFAULT 0 CHECK("living_rooms" >= 0),
    "dining_rooms" INTEGER NOT NULL DEFAULT 0 CHECK("dining_rooms" >= 0),
    "property_description" TEXT NOT NULL,
    "currency" TEXT NOT NULL,
    "active" INTEGER NOT NULL DEFAULT 0 CHECK("active" IN(0, 1)),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("owner_id") REFERENCES "owners"("id"),
    FOREIGN KEY ("location_id") REFERENCES "locations"("id")
);

-- ########################### RENTALS ###########################


-- ########################## AMENITIES ##########################

-- Represents amenities that can be applied on the rental properties
CREATE TABLE "amenities" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE, -- For example, pool, garden, hair dryer, etc...
    PRIMARY KEY ("id")
);


-- Junction table between amenities and rental properties
CREATE TABLE "property_amenities" (
    "property_id" INTEGER NOT NULL,
    "amenity_id" INTEGER NOT NULL,
    PRIMARY KEY ("property_id", "amenity_id"),
    FOREIGN KEY ("property_id") REFERENCES "properties"("id"),
    FOREIGN KEY ("amenity_id") REFERENCES "amenities"("id")
);

-- ########################## AMENITIES ##########################


-- ################### PRICES AND AVAILABILITY ###################

-- Represents date ranges on properties which are NOT available; whether marked by the owner or booking or otherwise
CREATE TABLE "availability" (
    "id" INTEGER,
    "property_id" INTEGER NOT NULL,
    "booking_id" INTEGER,
    "start_date" DATE CHECK("start_date" < "end_date"),
    "end_date" DATE CHECK("end_date" > "start_date"),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("property_id") REFERENCES "properties"("id"),
    FOREIGN KEY ("booking_id") REFERENCES "bookings"("id")
);


-- Represents prices for dates, stored per day
CREATE TABLE "prices" (
    "property_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "price" INTEGER NOT NULL, -- Price stored in cents: 5 = $0.05, 50 = $0.50, 500 = $5.00.
    PRIMARY KEY ("property_id", "date"),
    FOREIGN KEY ("property_id") REFERENCES "properties"("id")
);

-- ################### PRICES AND AVAILABILITY ###################


-- ########################## BOOKINGS ###########################


-- Represents booking creations; !never! update booking_events table directly, always update bookings table. App logic should prevent duplicate entries.
CREATE TABLE "bookings" (
    "id" INTEGER,
    "property_id" INTEGER NOT NULL,
    "renter_id" INTEGER NOT NULL,
    "full_amount" INTEGER NOT NULL,
    "deposit_amount" INTEGER NOT NULL,
    "balance_amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "start_date" DATE NOT NULL CHECK("start_date" < "end_date"),
    "end_date" DATE NOT NULL CHECK("end_date" > "start_date"),
    "status" TEXT NOT NULL DEFAULT 'booked' CHECK ("status" IN ('booked', 'cancelled', 'in_progress', 'completed')),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("property_id") REFERENCES "properties"("id"),
    FOREIGN KEY ("renter_id") REFERENCES "renters"("id")
);


-- Tracks all changes in created bookings; !never! update booking_events table directly, always update bookings table
CREATE TABLE "booking_events" (
    "id" INTEGER,
    "booking_id" INTEGER NOT NULL,
    "property_id" INTEGER NOT NULL,
    "renter_id" INTEGER NOT NULL,
    "full_amount" INTEGER NOT NULL,
    "deposit_amount" INTEGER NOT NULL,
    "balance_amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "status" TEXT NOT NULL CHECK ("status" IN ('booked', 'cancelled', 'in_progress', 'completed')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("booking_id") REFERENCES "bookings"("id"),
    FOREIGN KEY ("property_id") REFERENCES "properties"("id"),
    FOREIGN KEY ("renter_id") REFERENCES "renters"("id")
);

-- ########################## BOOKINGS ###########################


-- ########################## PAYMENTS ###########################

-- Represents immutable booking payment records
CREATE TABLE "payments" (
    "id" INTEGER,
    "booking_id" INTEGER NOT NULL,
    "transaction_id" TEXT NOT NULL UNIQUE,
    "amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "payment_type" TEXT NOT NULL CHECK ("payment_type" IN ('payment', 'refund', 'fee')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("booking_id") REFERENCES "bookings"("id")
);


-- Represents the history of payment status changes
CREATE TABLE "payment_events" (
    "id" INTEGER,
    "payment_id" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending' CHECK ("status" IN ('pending', 'completed', 'failed', 'cancelled')),
    "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("payment_id") REFERENCES "payments"("id")
);

-- ########################## PAYMENTS ###########################


-- ######################### LOCATIONS ###########################

-- Represents the property location. Due to no single universal location standard, it is best left without any constraints
CREATE TABLE "locations" (
    "id" INTEGER,
    "country" TEXT NOT NULL,
    "region" TEXT,
    "province" TEXT,
    "municipality" TEXT,
    "city" TEXT,
    "street" TEXT,
    "street_number" TEXT,
    "latitude" REAL,
    "longitude" REAL,
    PRIMARY KEY ("id")
);

-- ######################### LOCATIONS ###########################


-- ############################################################## TRIGGERS ##############################################################
-- ######################################################################################################################################


-- ##################### BOOKING TRIGGERS ########################

-- Represents trigger that enters newly created bookings from the bookings table into booking_events table
CREATE TRIGGER "booking_creation"
AFTER INSERT ON "bookings"
BEGIN
    INSERT INTO "booking_events" (
        "booking_id",
        "property_id",
        "renter_id",
        "full_amount",
        "deposit_amount",
        "balance_amount",
        "currency",
        "start_date",
        "end_date",
        "status")
    VALUES (
        NEW."id",
        NEW."property_id",
        NEW."renter_id",
        NEW."full_amount",
        NEW."deposit_amount",
        NEW."balance_amount",
        NEW."currency",
        NEW."start_date",
        NEW."end_date",
        NEW."status");
END;


-- Represents trigger that records amendments to existing bookings from the bookings table into the booking_events table
CREATE TRIGGER "booking_amendment"
AFTER UPDATE ON "bookings"
BEGIN
    INSERT INTO "booking_events" (
        "booking_id",
        "property_id",
        "renter_id",
        "full_amount",
        "deposit_amount",
        "balance_amount",
        "currency",
        "start_date",
        "end_date",
        "status")
    VALUES (
        NEW."id",
        NEW."property_id",
        NEW."renter_id",
        NEW."full_amount",
        NEW."deposit_amount",
        NEW."balance_amount",
        NEW."currency",
        NEW."start_date",
        NEW."end_date",
        NEW."status");
END;

-- ##################### BOOKING TRIGGERS ########################


-- ##################### PAYMENT TRIGGERS ########################

-- Creates initial payment event when payment is created
CREATE TRIGGER "payment_creation"
AFTER INSERT ON "payments"
BEGIN
    INSERT INTO "payment_events" ("payment_id", "status")
    VALUES (NEW."id", 'pending');
END;


-- Prevents direct updates to payments table
CREATE TRIGGER "prevent_payment_update"
BEFORE UPDATE ON "payments"
BEGIN
    SELECT RAISE(ABORT, 'payments table is immutable');
END;


-- Prevents direct deletes from payments table
CREATE TRIGGER "prevent_payment_delete"
BEFORE DELETE ON "payments"
BEGIN
    SELECT RAISE(ABORT, 'payments table is immutable');
END;


-- Prevents direct updates to payment_events table
CREATE TRIGGER "prevent_payment_event_update"
BEFORE UPDATE ON "payment_events"
BEGIN
    SELECT RAISE(ABORT, 'only insert into payment_events table, do not update');
END;


-- Prevents direct deletes from payment_events table
CREATE TRIGGER "prevent_payment_events_delete"
BEFORE DELETE ON "payment_events"
BEGIN
    SELECT RAISE(ABORT, 'do not delete values from payment_events table, only insert');
END;

-- ##################### PAYMENT TRIGGERS ########################


-- ################## AVAILABILITY TRIGGERS ######################

-- Represents a trigger that adds property dates (start_date, end_date-1day) in availability table after a booking is created
CREATE TRIGGER "availability_per_booking"
AFTER INSERT ON "bookings"
BEGIN
    INSERT INTO "availability" (
        "booking_id",
        "property_id",
        "start_date",
        "end_date")
    VALUES (
        NEW."id",
        NEW."property_id",
        NEW."start_date",
        DATE(NEW."end_date", '-1 day'));
END;


-- Represents a trigger that updates availability on properties based on booking date updates
CREATE TRIGGER "booking_updates_availability"
AFTER UPDATE ON "bookings"
BEGIN
    UPDATE "availability"
    SET
        "start_date" = NEW."start_date",
        "end_date" = DATE(NEW."end_date", '-1 day')
    WHERE "booking_id" = NEW."id";
END;

-- Represents a trigger that removes availability on properties based on booking cancellations
CREATE TRIGGER "booking_cancellation_updates_availability"
AFTER UPDATE ON "bookings"
WHEN NEW."status" = 'cancelled'
BEGIN
    DELETE FROM "availability"
    WHERE "booking_id" = NEW."id";
END;

-- Represents a trigger that removes availability on properties based on booking completions
CREATE TRIGGER "booking_completion_updates_availability"
AFTER UPDATE ON "bookings"
WHEN NEW."status" = 'completed'
BEGIN
    DELETE FROM "availability"
    WHERE "booking_id" = NEW."id";
END;


-- ################## AVAILABILITY TRIGGERS ######################

-- ############################################################### INDEXES ##############################################################
-- ######################################################################################################################################


-- ###################### PROPERTIES INDEXES #######################

CREATE INDEX "properties_index_owner" ON "properties" ("owner_id");
CREATE INDEX "properties_index_location" ON "properties" ("location_id");
CREATE INDEX "properties_index_type" ON "properties" ("type");

-- ###################### PROPERTIES INDEXES #######################
-- ##################### AVAILABILITY INDEXES ######################

CREATE INDEX "availability_index_property" ON "availability" ("property_id");
CREATE INDEX "availability_index_bookings" ON "availability" ("booking_id");

-- ##################### AVAILABILITY INDEXES ######################
-- ####################### BOOKING INDEXES #########################

CREATE INDEX "bookings_index_property" ON "bookings" ("property_id");
CREATE INDEX "bookings_index_renter" ON "bookings" ("renter_id");
CREATE INDEX "bookings_index_price" ON "bookings" ("full_amount");
CREATE INDEX "bookings_index_status" ON "bookings" ("status");

CREATE INDEX "booking_events_status_created" ON "booking_events" ("status", "created_at");

-- ####################### BOOKING INDEXES #########################
-- ####################### PAYMENT INDEXES #########################

CREATE INDEX "payments_index_booking" ON "payments" ("booking_id");
CREATE INDEX "payments_index_type" ON "payments" ("payment_type");
CREATE INDEX "payments_index_created" ON "payments" ("created_at");

CREATE INDEX "payment_event_index_status_created" ON "payment_events" ("status", "created_at");

-- ####################### PAYMENT INDEXES #########################
-- ###################### LOCATION INDEXES #########################

CREATE INDEX "locations_index_country" ON "locations" ("country");
CREATE INDEX "locations_index_region" ON "locations" ("region");
CREATE INDEX "locations_index_province" ON "locations" ("province");
CREATE INDEX "locations_index_municipality" ON "locations" ("municipality");
CREATE INDEX "locations_index_city" ON "locations" ("city");

-- ###################### LOCATION INDEXES #########################


-- ################################################################ VIEWS ###############################################################
-- ######################################################################################################################################

-- #################################################################

-- View that shows all owners (company and private) with all details
CREATE VIEW "owners_list" AS
SELECT
    owners.id AS 'owner_id',
    owners.type AS 'owner_type',
    private_owners.first_name AS 'name',
    private_owners.last_name AS 'identifier',
    private_owners.email AS 'email'
FROM
    owners
JOIN
    private_owners
ON
    owners.id = private_owners.id
UNION
SELECT
    owners.id AS 'owner_id',
    owners.type AS 'owner_type',
    company_owners.name AS 'name',
    company_owners.company_reg_id AS 'identifier',
    company_owners.email AS 'email'
FROM
    owners
JOIN
    company_owners
ON
    owners.id = company_owners.id;

-- #################################################################

-- Query to find all properties with specific amenity (...WHERE "amenity" = 'pool' for example)
CREATE VIEW "properties_with_amenities" AS
SELECT
    properties.id AS 'property_id',
    properties.name AS 'property_name',
    amenities.name AS 'amenity'
FROM
    properties
JOIN
    property_amenities
ON
    properties.id = property_amenities.property_id
JOIN
    amenities
ON
    property_amenities.amenity_id = amenities.id;

-- #################################################################

-- Query to select all properties and owners (via email) they belong to/are managed by
CREATE VIEW "owners_and_properties" AS
SELECT
    owners.id AS 'owner_id',
    owners.type AS 'owner_type',
    company_owners.email AS 'owner_email',
    properties.id AS 'property_id',
    properties.name AS 'property_name'
FROM
    owners
JOIN
    company_owners ON owners.id = company_owners.id
JOIN
    properties ON company_owners.id = properties.owner_id
UNION
SELECT
    owners.id AS 'owner_id',
    owners.type AS 'owner_type',
    private_owners.email AS 'owner_email',
    properties.id AS 'property_id',
    properties.name AS 'property_name'
FROM
    owners
JOIN
    private_owners ON owners.id = private_owners.id
JOIN
    properties ON private_owners.id = properties.owner_id;

-- #################################################################

-- Query to track booking payments (WHERE booking_id = 1 for example) and their status changes over time
CREATE VIEW "booking_payments_ledger" AS
SELECT
    payments.id,
    payments.booking_id,
    payments.transaction_id,
    payments.amount,
    payment_events.status,
    payment_events.created_at
FROM
    payments
JOIN
    payment_events
ON
    payments.id = payment_events.payment_id
ORDER BY
    payment_events.created_at;

-- #################################################################
