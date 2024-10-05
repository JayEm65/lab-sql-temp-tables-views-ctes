-- Step 1: Create a View for Rental Summary
CREATE VIEW rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id;

-- Step 2: Create a Temporary Table for Total Paid by Each Customer
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    rs.customer_id,
    rs.customer_name,
    rs.email,
    SUM(p.amount) AS total_paid
FROM 
    rental_summary rs
LEFT JOIN 
    payment p ON rs.customer_id = p.customer_id
GROUP BY 
    rs.customer_id;

-- Step 3: Create a CTE for the Customer Summary Report
WITH customer_summary AS (
    SELECT 
        cps.customer_name,
        cps.email,
        rs.rental_count,
        cps.total_paid,
        CASE 
            WHEN rs.rental_count > 0 THEN cps.total_paid / rs.rental_count 
            ELSE 0 
        END AS average_payment_per_rental
    FROM 
        customer_payment_summary cps
    JOIN 
        rental_summary rs ON cps.customer_id = rs.customer_id
)

-- Final query to generate the Customer Summary Report
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM 
    customer_summary;
