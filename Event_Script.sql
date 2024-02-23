DROP EVENT IF EXISTS minute_test;

DELIMITER //

CREATE EVENT minute_test
ON SCHEDULE EVERY 1 MINUTE
DO BEGIN
    INSERT INTO invoices_audit VALUES
    (9999, 'test', 999.99, 'INSERTED', NOW());
END//

DELIMITER ;