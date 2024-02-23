USE ap;

DROP PROCEDURE IF EXISTS test;

-- Change statement delimiter from semicolon to double front slash
DELIMITER //

CREATE PROCEDURE test()
BEGIN
  DECLARE invoice_count   INT;

  SELECT COUNT(*)
  INTO invoice_count
  FROM invoices
  WHERE invoice_total - payment_total - credit_total >= 5000;
  
  SELECT CONCAT(invoice_count, ' invoices exceed $5000.') AS message;
END//

-- Change statement delimiter from semicolon to double front slash
DELIMITER ;

CALL test();


DROP PROCEDURE IF EXISTS test1;

-- Change statement delimiter from semicolon to double front slash
DELIMITER //

CREATE PROCEDURE test1()
BEGIN
  DECLARE count_balance_due   INT;
  DECLARE total_balance_due   DECIMAL(9,2);

  SELECT COUNT(*), SUM(invoice_total - payment_total - credit_total)
  INTO count_balance_due, total_balance_due
  FROM invoices
  WHERE invoice_total - payment_total - credit_total > 0;

  IF total_balance_due >= 30000 THEN
    SELECT count_balance_due AS count_balance_due, 
           total_balance_due AS total_balance_due;
  ELSE
    SELECT 'Total balance due is less than $30,000.' AS message;
  END IF;
END//

-- Change statement delimiter from semicolon to double front slash
DELIMITER ;

CALL test1();


DROP PROCEDURE IF EXISTS test2;

-- Change statement delimiter from semicolon to double front slash
DELIMITER //

CREATE PROCEDURE test2()
BEGIN
  DECLARE vendor_name_var     VARCHAR(50);
  DECLARE invoice_number_var  VARCHAR(50);
  DECLARE balance_due_var     DECIMAL(9,2);

  DECLARE s                   VARCHAR(400)   DEFAULT '';
  DECLARE row_not_found       INT            DEFAULT FALSE;
  
  DECLARE invoices_cursor CURSOR FOR
    SELECT vendor_name, invoice_number,
      invoice_total - payment_total - credit_total AS balance_due
    FROM vendors v JOIN invoices i
      ON v.vendor_id = i.vendor_id
    WHERE invoice_total - payment_total - credit_total >= 5000
    ORDER BY balance_due DESC;

  BEGIN
    DECLARE EXIT HANDLER FOR NOT FOUND
      SET row_not_found = TRUE;

    OPEN invoices_cursor;
    
    WHILE row_not_found = FALSE DO
      FETCH invoices_cursor 
      INTO vendor_name_var, invoice_number_var, balance_due_var;

      SET s = CONCAT(s, balance_due_var, '|',
                        invoice_number_var, '|',
                        vendor_name_var, '//');
    END WHILE;
  END;

  CLOSE invoices_cursor;    
  
  SELECT s AS message;
END//

-- Change statement delimiter from semicolon to double front slash
DELIMITER ;

CALL test2();

DROP PROCEDURE IF EXISTS test3;

DELIMITER //

CREATE PROCEDURE test3()
BEGIN
  DECLARE column_cannot_be_null TINYINT DEFAULT FALSE;

  DECLARE CONTINUE HANDLER FOR 1048
    SET column_cannot_be_null = TRUE;

  UPDATE invoices
  SET invoice_due_date = NULL
  WHERE invoice_id = 1;
  
  IF column_cannot_be_null = TRUE THEN
    SELECT 'Row was not updated - column cannot be null.' AS message;
  ELSE
    SELECT '1 row was updated.' AS message;    
  END IF;

END//

DELIMITER ;

CALL test3();

DROP PROCEDURE IF EXISTS test4;

-- Change statement delimiter from semicolon to double front slash
DELIMITER //

CREATE PROCEDURE test4()
BEGIN
  DECLARE vendor_name_var     VARCHAR(50);
  DECLARE invoice_number_var  VARCHAR(50);
  DECLARE balance_due_var     DECIMAL(9,2);

  DECLARE s                   VARCHAR(400)   DEFAULT '';
  DECLARE row_not_found       INT            DEFAULT FALSE;
  
  DECLARE invoices_cursor CURSOR FOR
    SELECT vendor_name, invoice_number,
      invoice_total - payment_total - credit_total AS balance_due
    FROM vendors v JOIN invoices i
      ON v.vendor_id = i.vendor_id
    WHERE invoice_total - payment_total - credit_total >= 5000
    ORDER BY balance_due DESC;

  -- Loop 1
  BEGIN
    DECLARE EXIT HANDLER FOR NOT FOUND
      SET row_not_found = TRUE;

    OPEN invoices_cursor;
    
    SET s = CONCAT(s, '$20,000 or More: ');      
                             
    WHILE row_not_found = FALSE DO
      FETCH invoices_cursor 
      INTO vendor_name_var, invoice_number_var, balance_due_var;

      IF balance_due_var >= 20000 THEN
        SET s = CONCAT(s, balance_due_var, '|',
                          invoice_number_var, '|',
                          vendor_name_var, '//');
      END IF;
    END WHILE;    
  END;

  CLOSE invoices_cursor;    

  -- Loop 2
  SET row_not_found = FALSE;
  BEGIN
    DECLARE EXIT HANDLER FOR NOT FOUND
      SET row_not_found = TRUE;

    OPEN invoices_cursor;
    
    SET s = CONCAT(s, '$10,000 to $20,000: ');
        
    WHILE row_not_found = FALSE DO
      FETCH invoices_cursor 
      INTO vendor_name_var, invoice_number_var, balance_due_var;

      IF balance_due_var >= 10000 AND balance_due_var < 20000 THEN
        SET s = CONCAT(s, balance_due_var, '|',
                          invoice_number_var, '|',
                          vendor_name_var, '//');
      END IF;
    END WHILE;    
  END;

  CLOSE invoices_cursor;    

  -- Loop 3
  SET row_not_found = FALSE;
  BEGIN
    DECLARE EXIT HANDLER FOR NOT FOUND
      SET row_not_found = TRUE;

    OPEN invoices_cursor;
    
    SET s = CONCAT(s, '$5,000 to $10,000: ');
        
    WHILE row_not_found = FALSE DO
      FETCH invoices_cursor 
      INTO vendor_name_var, invoice_number_var, balance_due_var;

      IF balance_due_var >= 5000 AND balance_due_var < 10000 THEN
        SET s = CONCAT(s, balance_due_var, '|',
                          invoice_number_var, '|',
                          vendor_name_var, '//');
      END IF;
    END WHILE;    
  END;

  CLOSE invoices_cursor;    
  
  -- Display the string variable
  SELECT s AS message;
END//
    
-- Change statement delimiter from semicolon to double front slash
DELIMITER ;

CALL test4();

DROP PROCEDURE IF EXISTS test5;

DELIMITER //

CREATE PROCEDURE test5()
BEGIN
  DECLARE sql_error INT DEFAULT FALSE;
  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET sql_error = TRUE;

  START TRANSACTION;
  
  UPDATE invoices
  SET vendor_id = 123
  WHERE vendor_id = 122;

  DELETE FROM vendors
  WHERE vendor_id = 122;

  UPDATE vendors
  SET vendor_name = 'FedUP'
  WHERE vendor_id = 123;

  IF sql_error = FALSE THEN
    COMMIT;
    SELECT 'The transaction was committed.';
  ELSE
    ROLLBACK;
    SELECT 'The transaction was rolled back.';
  END IF;
END//

DELIMITER ;

CALL test5();

DROP PROCEDURE IF EXISTS test6;

DELIMITER //

CREATE PROCEDURE test6()
BEGIN
  DECLARE sql_error INT DEFAULT FALSE;
  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET sql_error = TRUE;

  START TRANSACTION;
  
  DELETE FROM invoice_line_items
  WHERE invoice_id = 114;

  DELETE FROM invoices
  WHERE invoice_id = 114;

  COMMIT;
  
  IF sql_error = FALSE THEN
    COMMIT;
    SELECT 'The transaction was committed.';
  ELSE
    ROLLBACK;
    SELECT 'The transaction was rolled back.';
  END IF;
END//

DELIMITER ;

CALL test6();

DROP PROCEDURE IF EXISTS insert_terms;

DELIMITER //

CREATE PROCEDURE insert_terms
(
  terms_due_days_param      INT,
  terms_description_param    VARCHAR(50)
)
BEGIN  
  DECLARE sql_error TINYINT DEFAULT FALSE;
  
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET sql_error = TRUE;
    
  -- Set default values for NULL values
  IF terms_description_param IS NULL THEN
    SET terms_description_param = CONCAT('Net due ', terms_due_days_param, ' days');
  END IF;

  START TRANSACTION;
  
  INSERT INTO terms
  VALUES (DEFAULT, terms_description_param, terms_due_days_param);
  
  IF sql_error = FALSE THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END//

DELIMITER ;

CALL insert_terms (120, 'Net due 120 days');
CALL insert_terms (150, NULL);

-- Clean up
DELETE FROM terms WHERE terms_id > 5;