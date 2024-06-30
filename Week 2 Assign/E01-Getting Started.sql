-- EO1 - Getting Started
-- Data Loading Utilities into Microsoft SQL Server

CREATE DATABASE Assignment1;
GO
USE Assignment1;

-- Creating the table
CREATE TABLE users (
    user_id INT IDENTITY PRIMARY KEY,
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated BIT DEFAULT 0,
    user_password VARCHAR(200),
    user_role VARCHAR(1) NOT NULL DEFAULT 'U', --U and A
    is_active BIT DEFAULT 0,
    created_dt DATE DEFAULT GETDATE()
);

SELECT * FROM users;

-- Using Bulk insert example
BULK INSERT users
FROM 'C:\data\users.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

--validating table filed
SELECT * FROM users;
GO
