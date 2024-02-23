DROP TRIGGER IF EXISTS invoices_before_update;

DELIMITER //

CREATE TRIGGER invoices_before_update
  BEFORE UPDATE ON invoices
  FOR EACH ROW
BEGIN
  DECLARE sum_line_item_amount DECIMAL(9,2);
  
  SELECT SUM(line_item_amount) 
  INTO sum_line_item_amount
  FROM invoice_line_items
  WHERE invoice_id = NEW.invoice_id;
  
  IF sum_line_item_amount != NEW.invoice_total THEN
    SIGNAL SQLSTATE 'HY000'
      SET MESSAGE_TEXT = 'Line item total must match invoice total.';
  ELSEIF NEW.payment_total + NEW.credit_total > NEW.invoice_total THEN
    SIGNAL SQLSTATE 'HY000'
      SET MESSAGE_TEXT = 'Payment total + credit total can not be greater than invoice total.';
  END IF;
END//

DELIMITER ;

DROP TRIGGER IF EXISTS invoices_before_update;

DELIMITER //

CREATE TRIGGER invoices_before_update
  BEFORE UPDATE ON invoices
  FOR EACH ROW
BEGIN
  DECLARE sum_line_item_amount DECIMAL(9,2);
  
  SELECT SUM(line_item_amount) 
  INTO sum_line_item_amount
  FROM invoice_line_items
  WHERE invoice_id = NEW.invoice_id;
  
  IF sum_line_item_amount != NEW.invoice_total THEN
    SIGNAL SQLSTATE 'HY000'
      SET MESSAGE_TEXT = 'Line item total must match invoice total.';
  ELSEIF NEW.payment_total + NEW.credit_total > NEW.invoice_total THEN
    SIGNAL SQLSTATE 'HY000'
      SET MESSAGE_TEXT = 'Payment total + credit total can not be greater than invoice total.';
  END IF;
END//

DELIMITER ;
