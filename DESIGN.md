# Design Document

By Eldar Klimentić

Video Overview: https://youtu.be/HOs0HVpl1Y8

## Scope

HolibobsDB is a relational database designed to provide the entities and relationships necessary to meet the minimum requirements for a functioning holiday rental database where owners of the rental properties can add adverts, and where renters can select, book and pay to stay in those rentals. Therefore, the database consists of:

* Owners include all the necessary owner information
* Renters include all the necessary renter information
* Properties, which include basic rental information and description of the rental
* Amenities, which is a list of amenity names that can be assigned to a rental property advert
* Availability tracks a range of dates which marks which dates are NOT available on a rental property's calendar
* Prices store daily prices on each rental property
* Bookings is a list of bookings on rentals and all the most common details
* Payments represent payments, refunds and fees
* Locations are physical locations of rentals

Elements outside the scope of the project include photos, comments (both user and admin), reviews, messages, guests other than the renter who made the booking, and other elements that are not required for the basic functionality of the system.

## Functional Requirements

The database will support storing and managing owner and renter accounts, rental property advert information, location, availability and prices, bookings, payments and their respective history, while maintaining integrity and efficient owner, renter, booking and payment lookup.

## Represenation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### Owners

The `owners` table includes:

* `id`, which specifies the unique identifier of an owner account corresponding to the `id` columns in both child tables as an `INTEGER`. The column has the `PRIMARY KEY` constraint applied.
* `type`, which specifies whether the owner account is either private or company account, and therefore `CHECK` constraint is applied.

#### Private_Owners

The `private_owners` table includes:

* `id`, which specifies the unique identifier of the private owner account stored as an `INTEGER`--corresponding to the one in the parent table--and is therefore both `PRIMARY KEY` and `FOREIGN KEY` that `REFERENCES` `id` in the `owners` table.
* `first_name`, which specifies first name on the private owner account as a `TEXT`.
* `last_name`, which specifies last name on the private owner account as a `TEXT`.
* `email`, which specifies email address on the private owner account as `TEXT` and has a `UNIQUE` constraint applied so the same email address cannot be used twice for the private owner accounts.
* `password`, which specifies the hashed login password as `TEXT`. Passwords should never be stored in plain text.

#### Company_Owners

The `company_owners` table includes:

* `id`, which specifies the unique identifier for the company owner account stored as an `INTEGER`--corresponding to the one in the parent table--and is both `PRIMARY KEY` and `FOREIGN KEY` that `REFERENCES` `id` in the `owners` table.
* `name`, which specifies the name of the company owner account in the form of `TEXT`.
* `company_reg_id`, which specifies the real world registration identifier added to the company owner account as a `TEXT`.
* `email`, which specifies email address of the company owner account as `TEXT` and has a `UNIQUE` constraint applied so the same email address cannot be used twice for the company owner accounts.
* `password`, which specifies the hashed login password as `TEXT`.

#### Renters

The renters `table` includes:

* `id`, which specifies the unique identifier for a renter account as an `INTEGER`, and therefore has `PRIMARY KEY` constraint applied.
* `first_name`, which specifies the first name on the renter account stored as `TEXT`.
* `last_name`, which specifies the last name on the renter account stored as `TEXT`.
* `email`, which specifies the email address on the renter's account as `TEXT`, and has a `UNIQUE` constraint applied so the same email address cannot be used twice for renter accounts.
* `password`, which specifies the hashed login password as `TEXT`.

#### Properties

The `properties` table includes:

* `id`, which specifies the unique rental property identifier as an `INTEGER`, and therefore has `PRIMARY KEY` constraint applied.
* `name`, which specifies a rental property name as `TEXT`.
* `type`, which specifies a rental property type as a multiple choice between house, villa, gite, apartment, bungalow, etc. `Type` is a `TEXT` data type and has a `CHECK` constraint.
* `owner_id`, which specifies the unique identifier of the owner who added the rental property advert. It has `FOREIGN KEY` constraint applied which `REFERENCES` `id` column in the `owners` table as an `INTEGER`.
* `location_id`, which specifies the unique location identifier of the place where the rental property is physically located. It has `FOREIGN KEY` constraint applied which `REFERENCES` `id` column in the `locations` table as an `INTEGER`.
* `bedrooms`, which specifies an `INTEGER` data type and holds the number of bedrooms the rental property has. `CHECK` constraint is applied here, accepting only unsigned numbers.
* `sleeps`, which specifies the number of people the rental can sleep as `INTEGER`. `CHECK` constraint is applied here, accepting only unsigned numbers.
* `bathrooms`, which specifies the number of bathrooms in the rental property as `INTEGER`.  `CHECK` constraint is applied here, accepting only unsigned numbers.
* `wc`, which specifies the number of water closets in the rental property as `INTEGER`. `CHECK` constraint is applied here, accepting only unsigned numbers.
* `living_rooms`, which specifies the number of living rooms in the rental property as `INTEGER`. `CHECK` constraint is applied here, accepting only unsigned numbers.
* `dining_rooms`, which specifies the number of dining rooms in the rental property as `INTEGER`. `CHECK` constraint is applied here, accepting only unsigned numbers.
* `property_description`, which specifies property rental description in a form of text as a `TEXT`.
* `currency`, which specifies the currency in which the rental property's price is set as a `TEXT`.
* `active`, which indicates whether the rental property advert is active or not as an `INTEGER`. CHECK constraint is applied limiting the options between 0 and 1--inactive and active.

#### Amenities

The `amenities` table includes:

* `id`, which is a unique amenity identifier stored as an `INTEGER`. The column has `PRIMARY KEY` constraint applied.
* `name`, which is simply the name of the amenity stored as a `TEXT` with `UNIQUE` constraint applied.

#### Property_Amenities

The `property_amenities` table includes:

* `property_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `properties` table as an `INTEGER`.
* `amenity_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `amenities` table as an `INTEGER`. The two columns compose a composite `PRIMARY KEY` in order to avoid duplicate/redundant entries on a single property.

#### Availability

The `availability` table includes:

* `id`, which is a unique availability identifier assigned to a new (un)availability entry for a property rental as an `INTEGER`. As such, `PRIMARY KEY` constraint is applied to it.
* `property_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `properties` table as an `INTEGER`.
* `booking_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `bookings` table as an `INTEGER`.
* `start_date` marks the first day of the date range during which the rental property is unavailable for bookings as a `DATE`. The column has a `CHECK` constraint that ensures `start_date` is always earlier than `end_date`.
* `end_date` marks the last day of the date range during which the rental property is unavailable for bookings as a `DATE`. The column has a `CHECK` constraint that ensures `end_date` is always later than `start_date`.

#### Prices

The `prices` table includes:

* `property_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `properties` table as an `INTEGER`.
* `date`, which specifies the date for which the daily price is set as a `DATE`. Together with `property_id`, it forms a composite `PRIMARY KEY` to prevent duplicate price entries for the same property and date.
* `price` represents a rental proeprty's the daily booking cost as an `INTEGER`.

#### Bookings

The `bookings` table includes:

* `id`, which is a unique booking identifier as an `INTEGER`. As such, `PRIMARY KEY` constraint is applied to it.
* `property_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `properties` table as an `INTEGER`.
* `renter_id`, which specifies the unique identifier of the renter who made the booking. It has `FOREIGN KEY` constraint applied which `REFERENCES` `id` column in the `renters` table as an `INTEGER`.
* `full_amount`, which specifies the full cost of the booking as an `INTEGER`.
* `deposit_amount`, which specifies the initial payment amount to secure the booking as an `INTEGER`.
* `balance_amount`, which specifies the remaining payment amount for the booking as an `INTEGER`.
* `currency` specifies the currency in which the booking amount is stored as `TEXT`.
* `start_date` marks the first day of the bookings as a `DATE`. The column has a `CHECK` constraint that ensures `start_date` is always earlier than `end_date`.
* `end_date` marks the last day of the bookings as a `DATE`. The column has a `CHECK` constraint that ensures `end_date` is always later than `start_date`.
* `status`, which specifies current booking status as a `TEXT` and, since a booking can be either `booked`, `cancelled` or `completed`, `CHECK` constraint is applied.

#### Booking_Events

The `booking_events` table includes:

* `id`, which specifies the unique identifier for each new table entry, ei. booking amendment, as an `INTEGER`. The column has `PRIMARY KEY` constraint applied.
* `booking_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `bookings` table as an `INTEGER`.
* `property_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `properties` table as an `INTEGER`.
* `renter_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `renters` table as an `INTEGER`.
* `full_amount`, which specifies the full cost of the booking as an `INTEGER`.
* `deposit_amount`, which specifies the initial payment amount to secure the booking as an `INTEGER`.
* `balance_amount`, which specifies the remaining payment amount for the booking as an `INTEGER`.
* `currency` specifies the currency in which the booking amount is stored as `TEXT`.
* `start_date` marks the first day of the bookings as a `DATE`. The column has a `CHECK` constraint that ensures `start_date` is always earlier than `end_date`.
* `end_date` marks the last day of the bookings as a `DATE`. The column has a `CHECK` constraint that ensures `end_date` is always later than `start_date`.
* `status`, which specifies booking status at the time of the entry as a `TEXT` and, since a booking can be either `booked`, `cancelled` or `completed`, `CHECK` constraint is applied.
* `created_at` marks the time of the entry as a `TEXT` and has `CURRENT_TIMESTAMP` as a default value.

#### Payments

The `payments` table includes:

* `id`, which specifies the unique identifier for payment made as an `INTEGER`. The column has `PRIMARY KEY` constraint applied.
* `booking_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `bookings` table as an `INTEGER`.
* `transaction_id`, which specifies a unique payment identifier provided by the payment service provider as a `TEXT`.
* `amount`, which specifies the payment amount as an `INTEGER`.
* `currency` specifies the currency in which the payment is made stored as `TEXT`.
* `payment_type`, which specifies the type of payment--payment, refund or fee--and has `CHECK` constraint applied.
* `created_at` marks the time of the entry as a `TEXT` and has `CURRENT_TIMESTAMP` as a default value.

#### Payment_Events

The `payment_events` table includes:

* `id`,  which specifies the unique identifier for each new table entry, ei. payment update, as an `INTEGER`. The column has `PRIMARY KEY` constraint applied.
* `payment_id`, which has a `FOREIGN KEY` constraint applied, and references `id` column in the `payments` table as an `INTEGER`.
* `status`, which specifies payment status at the time of the entry as a `TEXT` and, since payments can be either `pending`, `completed`, `failed`, or `cancelled` a `CHECK` constraint is applied.
* `created_at` marks the time of the entry as a `TEXT` and has `CURRENT_TIMESTAMP` as a default value.

#### Locations

The `locations` table includes:

* `id`,  which specifies the unique identifier for each new location as an `INTEGER`. The column has `PRIMARY KEY` constraint applied.
* `country`, which specifies the country of the location as a `TEXT` and is the only column in the table that has `NOT NULL` constraint applied.
* `region`, which specifies the region of the location as a `TEXT`.
* `province`, which specifies the province of the location as a `TEXT`.
* `municipality`, which specifies the municipality of the location as a `TEXT`.
* `city`, which specifies the city of the location as a `TEXT`.
* `street`, which specifies the street of the location as a `TEXT`.
* `street_number`, which specifies the street number of the location as a `TEXT`.
* `latitude`, which specifies the latitude of the location as a `REAL`.
* `longitude`, which specifies the longitude of the location as a `REAL`.

### Relationships

The diagram below describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed by the diagram:

* An owner can be either private or company owner. One owner can own between 0 and many properties. 0, if they haven't added any rental adverts, and many if the have added more than one. A property cannot be shared between owners.
* A booking must have exactly one property and exactly one renter. Zero or many payments can be made for a booking, and between 1 and many entries can be made in the booking_events.
* A renter can have 0 and many bookings, 0 if they haven't booked any rentals and many if they have booked multiple rentals; therefore, a single booking can have only one property and only one renter.
* In reality, a rental property will usually have at least one amenity. However, the database allows a property to have between 0 and many amenities. It is same with prices and availability on properties; a rental can have 0 or many prices, 0 or many unavailable date ranges. As mentioned before, a booking must have one and only one property, however, property can have between 0 and many bookings on it.
* Booking payments can be made in instalments or at once. Therefore, a booking can have between 0 and many payments, but a payment in payments can be one and only one and its status is tracked in the payment_events table. A payment has between 1 and many payment_events, since a payment gets an initial status event when created and can have later status changes.
* Multiple properties can share the same location, but each property must have exactly one location.

## Optimizations

Per the typical queries expected, indexes are created on columns that are frequently used for searching, filtering, and joining records. For properties, indexes are created on `owner_id`, `location_id`, and `type`, as users will commonly search properties by owner, location, or property category.

Similarly, indexes are created on booking-related columns such as `property_id`, `renter_id`, and `status`.

For payment and availability records, indexes are created on `booking_id`, `property_id`, `status`, and `created_at` to improve lookup of payment histories, booking availability periods, and event timelines.

Location fields such as `country`, `region`, `province`, `municipality`, and `city` are also indexed to improve rental property searches based on geographical criteria.

## Limitations

Due to the current scope of the database, several limitations exist. Owners and renters cannot communicate directly through the system, as messaging functionality is not implemented. Properties cannot store or reference images, and bookings only associate with the primary renter, without support for additional guests. Other limitations include the absence of reviews, comments, and other features mentioned as out of scope.
