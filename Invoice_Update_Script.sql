UPDATE invoices
SET credit_total = invoice_total * .1,
    payment_total = invoice_total - credit_total
WHERE invoice_id = 115;

UPDATE vendors
SET default_account_number = 403
WHERE vendor_id = 44;

UPDATE invoices
SET terms_id = 2
WHERE vendor_id IN
    (SELECT vendor_id
     FROM vendors
     WHERE default_terms_id = 2);
     
UPDATE vendor_address
SET vendor_address1 = '1990 Westwood Blvd',
    vendor_address2 = 'Ste 260'
WHERE vendor_id = 4;
