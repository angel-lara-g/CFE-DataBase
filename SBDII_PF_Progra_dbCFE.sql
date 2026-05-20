/*
Database Systems II
Final Project: dbCFE
Objective: Database Programming Script
José Ángel Lara Gómez
*/
-- Start

-- IMPORTANT:
--    1. Create objects in order, as some depend on others.
--    2. FA_facA() is a helper function required by PA_facAtrasadas().

-- Use the dbCFE database
USE dbCFE;


#############################################################################################################################
# 1. Stored procedure with input and output parameters

### Instructions:
-- Create a stored procedure (PA_estadoFact) that receives an invoice status
--    as input and returns the number of invoices with that status
--    and the earliest due date (used later by PA_facAtrasadas)

-- 1. Change the statement delimiter
DELIMITER //

-- 2. Create the stored procedure
CREATE PROCEDURE PA_estadoFact (IN estFac VARCHAR(50), OUT numFac INT, OUT fecLim DATE)
BEGIN
    -- Find the earliest due date among invoices with the given status
    SELECT MIN(fecha_limite)
    INTO fecLim
    FROM facturas
    WHERE factura_id IN (SELECT factura_id
                         FROM facturas
                         WHERE estado = estFac);

    -- Count the number of invoices with the given status
    SELECT COUNT(estado)
    INTO numFac
    FROM facturas
    WHERE estado = estFac;
END //

-- 3. Restore the statement delimiter
DELIMITER ;

-- 4. Call the stored procedure
CALL PA_estadoFact('Pendiente', @nuFac, @feLim);

-- 5. Query the output variables
SELECT @nuFac AS 'Número de facturas', @feLim AS 'Fecha límite menor';


#############################################################################################################################
# 2. Helper stored function for PA_facAtrasadas()

### Instructions:
-- Create a stored function (FA_facA) that receives an invoice ID
--    (obtained inside PA_facAtrasadas) and updates the invoice status
--    to 'Atrasada' (Overdue) if it is pending and past its due date,
--    returning a flag (1 if updated, 0 if not)

-- 1. Change the statement delimiter
DELIMITER //

-- 2. Create the stored function
CREATE FUNCTION FA_facA (fId INT)
RETURNS INT
DETERMINISTIC
BEGIN
    -- Variable declarations
    DECLARE fec  DATE;
    DECLARE est  VARCHAR(50);
    DECLARE band INT;

    -- Initialize flag
    SET band = 0;

    -- Get the status of the invoice with the given ID
    SET est := (SELECT estado
                FROM facturas
                WHERE factura_id = fId);

    -- Get the due date of the invoice with the given ID
    SET fec := (SELECT fecha_limite
                FROM facturas
                WHERE factura_id = fId);

    -- If the invoice is pending and past its due date, mark it as overdue
    IF est = 'Pendiente' AND fec < CURDATE() THEN
        UPDATE facturas
        SET estado = 'Atrasada'
        WHERE factura_id = fId;
        -- Set flag to indicate a change was made
        SET band = 1;
    END IF;

    RETURN (band);
END //


#############################################################################################################################
# 3. Stored procedure using conditionals

### Instructions:
-- Create a stored procedure (PA_facAtrasadas) that receives the @feLim
--    session variable (earliest due date from PA_estadoFact) and checks
--    whether that date is in the past. If not, it displays 'No hay cambios'
--    (No changes). Otherwise, it iterates over all invoices with a due date
--    on or after @feLim, calls FA_facA() on each one to update overdue invoices,
--    and finally displays all invoices that were marked as overdue.

-- 1. Change the statement delimiter
DELIMITER //

-- 2. Create the stored procedure
CREATE PROCEDURE PA_facAtrasadas (IN fLimMenor DATE)
BEGIN
    -- Variable declarations
    DECLARE id    INT;
    DECLARE maxi  INT;
    DECLARE res   INT;
    DECLARE band  INT;
    DECLARE est   VARCHAR(50);

    -- Initialize variables
    SET band = 0;
    SET maxi = 0;
    SET res  = 0;

    -- Count how many invoices exist from the given due date onward (loop iterations)
    SET maxi := (SELECT COUNT(*)
                 FROM facturas
                 WHERE fecha_limite >= fLimMenor);

    -- Get the ID of the first invoice with a due date equal to the given date
    SET id := (SELECT factura_id
               FROM facturas
               WHERE fecha_limite = fLimMenor
               LIMIT 1);

    -- Only proceed if the given due date is in the past
    IF fLimMenor < CURDATE() THEN
        REPEAT
            -- Call the helper function for the current invoice
            SET res  := FA_facA(id);
            -- Accumulate the result into the change flag
            SET band  = band + res;
            -- Move to the next invoice ID
            SET id    = id + 1;
            SET maxi  = maxi - 1;
        UNTIL maxi = 0
        END REPEAT;
    END IF;

    -- Report results: show a message if no changes, or display overdue invoices
    IF band < 1 THEN
        SELECT 'No hay cambios';
    ELSE
        SELECT *
        FROM facturas
        WHERE fecha_limite >= fLimMenor AND estado = 'Atrasada';
    END IF;
END //

-- 3. Restore the statement delimiter
DELIMITER ;

-- 4. Call the stored procedure using the session variable set by PA_estadoFact
CALL PA_facAtrasadas(@feLim);


#############################################################################################################################
# 4. Stored function

### Instructions:
-- Create a stored function (FA_sumPagos) that receives an invoice ID
--    (triggered by the AIpagos trigger after each payment insert),
--    sums all payments made toward that invoice, and returns the invoice
--    status: 'Pagada' (Paid) if the total payments cover the amount due,
--    or 'Pendiente' (Pending) otherwise.

-- 1. Change the statement delimiter
DELIMITER //

-- 2. Create the stored function
CREATE FUNCTION FA_sumPagos (fId INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    -- Variable declarations
    DECLARE est    VARCHAR(50);
    DECLARE suma   DECIMAL(10,2);
    DECLARE montoA DECIMAL(10,2);

    -- Sum all payments linked to the given invoice ID
    SET suma := (SELECT SUM(monto)
                 FROM pagos
                 WHERE factura_id = fId);

    -- Get the total amount due for the given invoice
    SET montoA := (SELECT monto
                   FROM facturas
                   WHERE factura_id = fId);

    -- Return the appropriate status based on the payment total
    IF suma >= montoA THEN
        RETURN ('Pagada');
    ELSE
        RETURN ('Pendiente');
    END IF;

END //


#############################################################################################################################
# 5. AFTER INSERT Trigger

### Instructions:
-- Create a trigger (AIpagos) that fires after a new payment is inserted.
--    It sums all payments for the related invoice and updates the invoice
--    status to 'Pagada' (Paid) if the total payments meet or exceed the amount due.

-- 1. Change the statement delimiter
DELIMITER //

-- 2. Create the trigger
CREATE TRIGGER AIpagos
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    UPDATE facturas
    SET estado = FA_sumPagos(NEW.factura_id)
    WHERE factura_id = NEW.factura_id;
END //

-- 3. Restore the statement delimiter
DELIMITER ;

-- 4. Display all triggers in the current database
SHOW TRIGGERS;

-- 5. Check the current status of invoice with ID = 9
SELECT factura_id, estado
FROM facturas
WHERE factura_id = 9;

-- 6. Insert a new payment toward invoice 9 (partial payment)
INSERT INTO PAGOS (factura_id, fecha_pago, monto, metodo_pago) VALUES
(9, '2024-05-20', 800.00, 'Tarjeta de crédito');

-- 7. Verify the invoice status was updated after the payment insert
SELECT factura_id, estado
FROM facturas
WHERE factura_id = 9;

-- End
