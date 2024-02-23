SELECT vendor_name, vendor_contact_last_name, vendor_contact_first_name
FROM vendors
ORDER BY vendor_contact_last_name, vendor_contact_first_name;

SELECT CONCAT(vendor_contact_last_name, ', ', vendor_contact_first_name) AS full_name
FROM vendors
WHERE vendor_contact_last_name < 'D' OR vendor_contact_last_name LIKE 'E%'
ORDER BY vendor_contact_last_name, vendor_contact_first_name;

SELECT invoice_due_date AS "Due Date", 
       invoice_total AS "Invoice Total", 
       invoice_total / 10 AS "10%",
       invoice_total * 1.1 AS "Plus 10%"
FROM invoices
WHERE invoice_total >= 500 AND invoice_total <= 1000
ORDER BY invoice_due_date DESC;

SELECT invoice_number,
       invoice_total,
       payment_total + credit_total AS payment_credit_total,
       invoice_total - payment_total - credit_total AS balance_due
FROM invoices
WHERE invoice_total - payment_total - credit_total > 50
ORDER BY balance_due DESC
LIMIT 5;

SELECT DATE_FORMAT(CURRENT_DATE, '%m-%d-%Y') AS "current_date";
SELECT invoice_number, 
       invoice_date, 
       invoice_total - payment_total - credit_total AS balance_due,
       payment_date
FROM invoices
WHERE payment_date IS NULL;
SELECT 50000 AS starting_principle,
       50000 * .065 AS interest,
       (50000) + (50000 * .065) AS principle_plus_interest;
       
SELECT *
FROM vendors JOIN invoices
  ON vendors.vendor_id = invoices.vendor_id;
  
SELECT vendor_name, invoice_number, invoice_date,
       invoice_total - payment_total - credit_total AS balance_due
FROM vendors v JOIN invoices i
  ON v.vendor_id = i.vendor_id
WHERE invoice_total - payment_total - credit_total <> 0
ORDER BY vendor_name;

SELECT vendor_name, default_account_number AS default_account, 
       account_description AS description
FROM vendors v JOIN general_ledger_accounts gl
  ON v.default_account_number = gl.account_number
ORDER BY account_description, vendor_name;

SELECT vendor_name, invoice_date, invoice_number, 
       invoice_sequence AS li_sequence,
       line_item_amount AS li_amount
FROM vendors v JOIN invoices i
  ON v.vendor_id = i.vendor_id
 JOIN invoice_line_items li
   ON i.invoice_id = li.invoice_id
ORDER BY vendor_name, invoice_date, invoice_number, invoice_sequence;

SELECT v1.vendor_id, 
       v1.vendor_name,
       CONCAT(v1.vendor_contact_first_name, ' ', v1.vendor_contact_last_name) AS contact_name
FROM vendors v1 JOIN vendors v2
    ON v1.vendor_id <> v2.vendor_id AND
       v1.vendor_contact_last_name = v2.vendor_contact_last_name  
ORDER BY v1.vendor_contact_last_name;

SELECT gl.account_number, account_description, invoice_id
FROM general_ledger_accounts gl LEFT JOIN invoice_line_items li
  ON gl.account_number = li.account_number
WHERE li.invoice_id IS NULL
ORDER BY gl.account_number;

  SELECT vendor_name, vendor_state
  FROM vendors
  WHERE vendor_state = 'CA'
UNION
  SELECT vendor_name, 'Outside CA'
  FROM vendors
  WHERE vendor_state <> 'CA'
ORDER BY vendor_name;

SELECT vendor_id, SUM(invoice_total) AS invoice_total_sum
FROM invoices
GROUP BY vendor_id;

SELECT vendor_name, SUM(payment_total) AS payment_total_sum
FROM vendors v JOIN invoices i
  ON v.vendor_id = i.vendor_id
GROUP BY vendor_name
ORDER BY payment_total_sum DESC;

SELECT account_description, COUNT(*) AS line_item_count,
       SUM(line_item_amount) AS line_item_amount_sum
FROM general_ledger_accounts gl 
  JOIN invoice_line_items li
    ON gl.account_number = li.account_number
GROUP BY account_description
HAVING line_item_count > 1
ORDER BY line_item_amount_sum DESC;

SELECT account_description, COUNT(*) AS line_item_count,
       SUM(line_item_amount) AS line_item_amount_sum
FROM general_ledger_accounts gl 
  JOIN invoice_line_items li
    ON gl.account_number = li.account_number
  JOIN invoices i
    ON li.invoice_id = i.invoice_id
WHERE invoice_date BETWEEN '2018-04-01' AND '2018-06-30'
GROUP BY account_description
HAVING line_item_count > 1
ORDER BY line_item_amount_sum DESC;

SELECT account_number, SUM(line_item_amount) AS line_item_sum
FROM invoice_line_items
GROUP BY account_number WITH ROLLUP;

SELECT vendor_name,
       COUNT(DISTINCT li.account_number) AS number_of_gl_accounts
FROM vendors v 
  JOIN invoices i
    ON v.vendor_id = i.vendor_id
  JOIN invoice_line_items li
    ON i.invoice_id = li.invoice_id
GROUP BY vendor_name
HAVING number_of_gl_accounts > 1
ORDER BY vendor_name;

SELECT IF(GROUPING(terms_id) = 1, 'Grand Totals', terms_id) AS terms_id,
       IF(GROUPING(vendor_id) = 1, 'Terms ID Totals', vendor_id) AS vendor_id,
       MAX(payment_date) AS max_payment_date,
       SUM(invoice_total - credit_total - payment_total) AS balance_due
FROM invoices
GROUP BY terms_id, vendor_id WITH ROLLUP;

SELECT vendor_id, invoice_total - payment_total - credit_total AS balance_due,
	   SUM(invoice_total - payment_total - credit_total) OVER() AS total_due,
       SUM(invoice_total - payment_total - credit_total) OVER(PARTITION BY vendor_id
           ORDER BY invoice_total - payment_total - credit_total) AS vendor_due
FROM invoices
WHERE invoice_total - payment_total - credit_total > 0;

SELECT vendor_id, invoice_total - payment_total - credit_total AS balance_due,
	   SUM(invoice_total - payment_total - credit_total) OVER() AS total_due,
       SUM(invoice_total - payment_total - credit_total) OVER vendor_window AS vendor_due,
       ROUND(AVG(invoice_total - payment_total - credit_total) OVER vendor_window, 2) AS vendor_avg
FROM invoices
WHERE invoice_total - payment_total - credit_total > 0
WINDOW vendor_window AS (PARTITION BY vendor_id ORDER BY invoice_total - payment_total - credit_total);

SELECT MONTH(invoice_date) AS month, SUM(invoice_total) AS total_invoices,
       ROUND(AVG(SUM(invoice_total)) OVER(ORDER BY MONTH(invoice_date)
           RANGE BETWEEN 3 PRECEDING AND CURRENT ROW), 2) AS 4_month_avg
FROM invoices
GROUP BY MONTH(invoice_date);

SELECT invoice_number, invoice_total
FROM invoices
WHERE payment_total >
     (SELECT AVG(payment_total)
      FROM invoices
      WHERE payment_total > 0)
ORDER BY invoice_total DESC;

SELECT account_number, account_description
FROM general_ledger_accounts gl
WHERE NOT EXISTS
    (SELECT *
     FROM invoice_line_items
     WHERE account_number = gl.account_number)
ORDER BY account_number;

SELECT SUM(invoice_max) AS sum_of_maximums
FROM (SELECT vendor_id, MAX(invoice_total) AS invoice_max
      FROM invoices
      WHERE invoice_total - credit_total - payment_total > 0
      GROUP BY vendor_id) t;
      
SELECT vendor_name, i.invoice_id, invoice_sequence, line_item_amount
FROM vendors v JOIN invoices i
  ON v.vendor_id = i.vendor_id
JOIN invoice_line_items li
  ON i.invoice_id = li.invoice_id
WHERE i.invoice_id IN
      (SELECT DISTINCT invoice_id
       FROM invoice_line_items               
       WHERE invoice_sequence > 1)
ORDER BY vendor_name, i.invoice_id, invoice_sequence;

SELECT vendor_name, vendor_city, vendor_state
FROM vendors
WHERE CONCAT(vendor_state, vendor_city) NOT IN 
    (SELECT CONCAT(vendor_state, vendor_city) as vendor_city_state
     FROM vendors
     GROUP BY vendor_city_state
     HAVING COUNT(*) > 1)
ORDER BY vendor_state, vendor_city;

SELECT vendor_name, invoice_number,
       invoice_date, invoice_total
FROM invoices i JOIN vendors v
  ON i.vendor_id = v.vendor_id
WHERE invoice_date =
  (SELECT MIN(invoice_date)
   FROM invoices 
   WHERE vendor_id = i.vendor_id)
ORDER BY vendor_name;

SELECT vendor_name, invoice_number,
       invoice_date, invoice_total
FROM invoices i
    JOIN
    (
      SELECT vendor_id, MIN(invoice_date) AS oldest_invoice_date
      FROM invoices
      GROUP BY vendor_id
    ) oi
    ON i.vendor_id = oi.vendor_id AND
       i.invoice_date = oi.oldest_invoice_date
    JOIN vendors v
    ON i.vendor_id = v.vendor_id
ORDER BY vendor_name;

WITH max_invoice AS
(
	SELECT vendor_id, MAX(invoice_total) AS invoice_max
    FROM invoices
    WHERE invoice_total - credit_total - payment_total > 0
    GROUP BY vendor_id
)
SELECT SUM(invoice_max) AS sum_of_maximums
FROM max_invoice;

SELECT invoice_total,
       FORMAT(invoice_total, 1) AS total_format,
       CONVERT(invoice_total, SIGNED) AS total_convert, 
       CAST(invoice_total AS SIGNED) AS total_cast
FROM invoices;
SELECT invoice_date, 
       CAST(invoice_date AS DATETIME) AS invoice_datetime, 
       CAST(invoice_date AS CHAR(7)) AS invoice_char7
FROM invoices;

SELECT invoice_total, ROUND(invoice_total, 1) AS one_digit, 
    ROUND(invoice_total, 0) AS zero_digits_round,
    TRUNCATE(invoice_total, 0) AS zero_digits_truncate
FROM invoices;

SELECT vendor_name,
    UPPER(vendor_name) AS vendor_name_upper,
    vendor_phone,
    SUBSTRING(vendor_phone, 11) AS last_digits,
    REPLACE(REPLACE(REPLACE(vendor_phone, '(', ''), ') ', '.'), '-', '.') AS phone_with_dots,
    IF(LOCATE(' ', vendor_name) = 0,
        '',
		IF(LOCATE(' ', vendor_name, LOCATE(' ', vendor_name) + 1) = 0,
			SUBSTRING(vendor_name, LOCATE(' ', vendor_name) + 1),
			SUBSTRING(vendor_name,
				LOCATE(' ', vendor_name) + 1,
                LOCATE(' ', vendor_name, LOCATE(' ', vendor_name) + 1) - LOCATE(' ', vendor_name))))
    AS second_word
FROM vendors;

SELECT invoice_number,
       invoice_date,
       DATE_ADD(invoice_date, INTERVAL 30 DAY) AS date_plus_30_days,
       payment_date,
       DATEDIFF(payment_date, invoice_date) AS days_to_pay,
       MONTH(invoice_date) AS "month",
       YEAR(invoice_date) AS "year"
FROM invoices
WHERE invoice_date > '2018-04-30' AND invoice_date < '2018-06-01';

SELECT invoice_number, invoice_total - payment_total - credit_total AS balance_due,
	   RANK() OVER(ORDER BY invoice_total - payment_total - credit_total DESC) AS balance_rank
FROM invoices
WHERE invoice_total - payment_total - credit_total > 0;

CREATE OR REPLACE VIEW open_items
AS
SELECT vendor_name, invoice_number, invoice_total,
  invoice_total - payment_total - credit_total AS balance_due
FROM  vendors JOIN invoices
  ON vendors.vendor_id = invoices.vendor_id
WHERE invoice_total - payment_total - credit_total > 0
ORDER BY vendor_name;

CREATE OR REPLACE VIEW open_items_summary
AS
SELECT vendor_name, COUNT(*) AS open_item_count,
       SUM(invoice_total - credit_total - payment_total) AS open_item_total
FROM vendors JOIN invoices
  ON vendors.vendor_id = invoices.vendor_id
WHERE invoice_total - credit_total - payment_total > 0
GROUP BY vendor_name
ORDER BY open_item_total DESC;
