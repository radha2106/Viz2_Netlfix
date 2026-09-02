/* These code create a database called 'Netflix'
   It creates the schema to be used and its tables neccessary.
   It has 9 dimensional tables, 4 facts tables, 12 views tables (one per region)
   Each table has it indexs and connections (primary and foreign keys)
   Information data comes from csv and txt files, while it is created using python
*/ 

--Create database, use it and create schema
CREATE DATABASE netflix
USE netflix;
GO
CREATE SCHEMA nfx;
GO

-- Create Dimensional Tables
	-- Calendar Table
CREATE TABLE nfx.calendar(
idx BIGINT NOT NULL IDENTITY(1,1),
dates DATE NOT NULL,
years INT NOT NULL,
months INT NOT NULL,
name_month VARCHAR(3) NOT NULL,
days_month INT NOT NULL,
day_week INT NOT NULL,
day_name VARCHAR(3) NOT NULL,
end_month DATE NOT NULL,
quarters INT NOT NULL,
week_start DATE NOT NULL,
week_end DATE NOT NULL,
weeks VARCHAR(7) NOT NULL,
week_year INT NOT NULL,
month_year VARCHAR(6) NOT NULL,
ini_month VARCHAR(1) NOT NULL,
year_offset INT NOT NULL,
month_offset INT NOT NULL,
week_offset INT NOT NULL
CONSTRAINT PK_calendar PRIMARY KEY (idx),
CONSTRAINT UQ_calendar UNIQUE (dates)
);
	-- Pay Method Table
CREATE TABLE nfx.pays(
idx BIGINT NOT NULL IDENTITY(1,1),
payment VARCHAR(11) NOT NULL,
CONSTRAINT PK_payment PRIMARY KEY (idx),
CONSTRAINT UQ_payment UNIQUE (payment)
);
	-- Languages Table
CREATE TABLE nfx.languages(
idx BIGINT NOT NULL IDENTITY(1,1),
languages VARCHAR(8) NOT NULL,
CONSTRAINT PK_languages PRIMARY KEY (idx),
CONSTRAINT UQ_languages UNIQUE (languages)
);
	-- Devices Table
CREATE TABLE nfx.devices(
idx BIGINT NOT NULL IDENTITY(1,1),
device VARCHAR(6) NOT NULL,
CONSTRAINT PK_devices PRIMARY KEY (idx),
CONSTRAINT UQ_devices UNIQUE (device)
);
	-- Categories Table
CREATE TABLE nfx.categories(
idx BIGINT NOT NULL IDENTITY(1,1),
categories VARCHAR(29) NOT NULL,
CONSTRAINT PK_category PRIMARY KEY (idx),
CONSTRAINT UQ_category UNIQUE (categories)
);
	-- Plans Table
CREATE TABLE nfx.plans(
idx BIGINT NOT NULL IDENTITY(1,1),
subs VARCHAR(4) NOT NULL,
price INT NOT NULL,
daysplan INT NOT NULL,
CONSTRAINT PK_plans PRIMARY KEY (idx),
CONSTRAINT UQ_subs UNIQUE (subs),
CONSTRAINT UQ_price UNIQUE (price),
CONSTRAINT UQ_dayplan UNIQUE (daysplan)
);
	-- Production Table
CREATE TABLE nfx.production(
idx BIGINT NOT NULL IDENTITY(1,1),
productions VARCHAR(5) NOT NULL,
modes VARCHAR(8) NOT NULL,
CONSTRAINT PK_production PRIMARY KEY (idx)
);
	-- Rating Table
CREATE TABLE nfx.rating(
idx BIGINT NOT NULL IDENTITY(1,1),
rates VARCHAR(10) NOT NULL,
CONSTRAINT PK_rating PRIMARY KEY (idx),
CONSTRAINT UQ_rates UNIQUE (rates)
);
	-- State Table
CREATE TABLE nfx.states(
idx BIGINT NOT NULL IDENTITY(1,1),
state_code VARCHAR(2) NOT NULL,
state_name VARCHAR(14) NOT NULL,
regions VARCHAR(7) NOT NULL,
CONSTRAINT PK_state PRIMARY KEY (idx),
CONSTRAINT UQ_names UNIQUE (state_code,state_name)
);

-- INDEXS
	-- Calendar Index
CREATE INDEX ix_calendar
ON nfx.calendar(dates,years,
name_month,end_month);

	-- Pays Index
CREATE INDEX ix_pays
ON nfx.pays(payment);

	-- Language Index
CREATE INDEX ix_langs
ON nfx.languages(languages);

	-- Devices Index
CREATE INDEX ix_devs
ON nfx.devices(device);

	-- Categories Index
CREATE INDEX ix_catg
ON nfx.categories(categories);

	-- Plan Index
CREATE INDEX ix_plan
ON nfx.plans(subs,price);

	-- Production Index
CREATE INDEX ix_prod
ON nfx.production(productions,modes);

	-- Rating Index
CREATE INDEX ix_rate
ON nfx.rating(rates);

	-- State Index
CREATE INDEX ix_states
ON nfx.states(state_name,regions);

-- Fact Tables
	-- Program Table
CREATE TABLE nfx.programs(
idx BIGINT IDENTITY(1,1) NOT NULL,
uploaded_on BIGINT NOT NULL,
lang_id BIGINT NOT NULL,
catg_id BIGINT NOT NULL,
produc_id BIGINT NOT NULL,
CONSTRAINT PK_prg PRIMARY KEY (idx),
CONSTRAINT FK_prg_uploaded FOREIGN KEY (uploaded_on) 
    REFERENCES nfx.calendar(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_prg_lang FOREIGN KEY (lang_id) 
    REFERENCES nfx.languages(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_prg_catg FOREIGN KEY (catg_id) 
    REFERENCES nfx.categories(idx)    
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_prg_prod FOREIGN KEY (produc_id) 
    REFERENCES nfx.production(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

	-- User Table
CREATE TABLE nfx.users(
idx BIGINT IDENTITY(1,1) NOT NULL,
created_on BIGINT NOT NULL,
state_id BIGINT NOT NULL,
sub_id BIGINT NOT NULL,
pay_id BIGINT NOT NULL,
dev_id BIGINT NOT NULL,
acct_state INT NOT NULL DEFAULT 1,
CONSTRAINT PK_users PRIMARY KEY (idx),
CONSTRAINT FK_user_state FOREIGN KEY (state_id) 
    REFERENCES nfx.states(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_user_date FOREIGN KEY (created_on) 
    REFERENCES nfx.calendar(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_user_sub FOREIGN KEY (sub_id) 
    REFERENCES nfx.plans(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_user_dev FOREIGN KEY (dev_id) 
    REFERENCES nfx.devices(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_user_pay FOREIGN KEY (pay_id) 
    REFERENCES nfx.pays(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

	-- Renewal Table
CREATE TABLE nfx.renewals(
users_id BIGINT NOT NULL,
plan_id BIGINT NOT NULL,
plan_start BIGINT NOT NULL,
plan_end BIGINT NOT NULL,
rnw_status INT NOT NULL CHECK(rnw_status = 0 AND rnw_status = 1),
CONSTRAINT FK_rw_user FOREIGN KEY (users_id) 
    REFERENCES nfx.users(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_rw_plan FOREIGN KEY (plan_id) 
    REFERENCES nfx.plans(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
CONSTRAINT FK_rw_plan_start FOREIGN KEY (plan_start) 
    REFERENCES nfx.calendar(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION  
);

	-- Viewx Table
CREATE TABLE nfx.viewx(
users_id BIGINT NOT NULL,
prg_id BIGINT NOT NULL,
dev_id BIGINT NOT NULL,
rate_id BIGINT NOT NULL,
view_on BIGINT NOT NULL,
CONSTRAINT FK_view_user FOREIGN KEY (users_id) 
    REFERENCES nfx.users(idx)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
CONSTRAINT FK_view_date FOREIGN KEY (view_on) 
    REFERENCES nfx.calendar(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
CONSTRAINT FK_view_prg FOREIGN KEY (prg_id) 
    REFERENCES nfx.programs(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
CONSTRAINT FK_view_prg_rate FOREIGN KEY (rate_id) 
    REFERENCES nfx.rating(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
CONSTRAINT FK_view_dev FOREIGN KEY (dev_id) 
    REFERENCES nfx.devices(idx)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
);

-- Fact Tables Indexs 
    -- User Index
CREATE INDEX ix_user
ON nfx.users(state_id,created_on,
sub_id,dev_id,pay_id);

    -- Views Index
CREATE INDEX ix_views
ON nfx.viewx(users_id,view_on,
prg_id,rate_id,dev_id);

    -- Programs Index
CREATE INDEX ix_programs
ON nfx.programs(uploaded_on,lang_id,catg_id,produc_id);

    -- Renewal Index
CREATE INDEX ix_renewal
ON nfx.renewal(users_id,plan_id,plan_start);

--View Tables
	-- Users Regions Tables
CREATE OR ALTER VIEW nfx.central_users AS --change view table name
SELECT
u.idx AS users,
created_on,
state_id AS state_nbr,
sub_id AS plan_type,
pay_id AS payment_type,
dev_id AS device_type,
plan_start,
SUM(price) as total_price_plan
FROM nfx.users AS u
INNER JOIN nfx.renewals AS r
ON u.idx = r.users_id
INNER JOIN nfx.states AS s
ON s.idx = u.state_id
INNER JOIN nfx.plans AS p
ON p.idx = u.sub_id
INNER JOIN nfx.calendar AS c
ON c.idx = r.plan_start
WHERE regions = 'central' --change filter name region
GROUP BY
u.idx,
created_on,
state_id,
sub_id,
pay_id,
dev_id,
plan_start;
GO
	-- Views Regions Tables
CREATE OR ALTER VIEW nfx.central_views AS --change view table name
SELECT DISTINCT
state_id AS states,
prg_id AS program_viewed,
view_on AS date_viewed,
v.dev_id AS viewed_on,
rate_id AS program_rating
FROM nfx.viewx AS v
INNER JOIN nfx.users AS u
ON v.users_id = u.idx
INNER JOIN nfx.states AS s
ON u.state_id = s.idx
INNER JOIN nfx.calendar AS c
ON c.idx = v.view_on
WHERE regions = 'central'; --change filter name region
GO

-- Bulk inserts csv
BULK INSERT --table
FROM ---file path
WITH (
	FIRSTROW=2,
	FIELDTERMINATOR=',',
	ROWTERMINATOR = '\n'
	);

-- Triggers
/* Trigger check_scammer_view
Create the Trigger called "check_scammer_view"
The trigger fires AFTER any INSERT operation on the viewsx table.*/
CREATE OR ALTER TRIGGER [nfx].[check_scammer_view]
ON [nfx].[viewx]
AFTER INSERT
AS
BEGIN
    /* Check if any row of the Viewx Table
    A violation means the View Date is EARLIER THAN the Creation Date of the Program.*/
    IF EXISTS (
        SELECT 1
        FROM inserted AS i  -- The data being inserted (Viewx Table)
        INNER JOIN nfx.programs AS p
            ON p.idx = i.prg_id
        INNER JOIN nfx.calendar AS c -- Joins to get the actual view date (Calendar Table)
            ON c.idx = i.view_on
        INNER JOIN nfx.calendar AS c1 -- Joins to get the actual creation date
            ON c1.idx = p.uploaded_on
        WHERE 
            c.idx < c1.idx
    )
    BEGIN
        -- If violations are found:        
        -- Undo the entire INSERT operation.
        ROLLBACK TRANSACTION;
        
        -- Using the modern THROW command to show error message
        THROW 50001,'Invalid Data Integrity: User cannot see a program before it is released.', 1;        
        -- Exit the trigger execution
        RETURN;
    END
END
GO

/* Trigger scammer_active
Create the Trigger called "scammer_active"
The trigger fires AFTER any INSERT operation on the viewsx table.*/
CREATE OR ALTER TRIGGER [nfx].[scammer_active]
ON [nfx].[viewx]
AFTER INSERT
AS
BEGIN
    -- Check from the USER table its account status is 0
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN nfx.users AS u ON i.users_id = u.idx
        WHERE u.status_id = 0
    )
    BEGIN
        -- If any inactive user is found, stop the entire insertion transaction.
        ROLLBACK TRANSACTION;
        
        -- Using the modern THROW command (Requires SQL Server 2012 or later)
        THROW 50001, 'Cannot record visit: One or more associated users are currently inactive (status 0).', 1;
    END
END
GO