/*
Database Systems II
Final Project: dbCFE
Objective: QL Script
José Ángel Lara Gómez
*/
-- Start

-- Use the dbCFE database
USE dbCFE;

-- View all records in each table
SELECT * FROM CLIENTES;
SELECT * FROM CONTRATOS;
SELECT * FROM SUMINISTROS;
SELECT * FROM FACTURAS;
SELECT * FROM PAGOS;


#############################################################################################################################
# 2 Views using MySQL predefined functions
# - GROUP_CONCAT() / Concatenates values from a group into a single comma-separated string
# - FIND_IN_SET()  / Searches for a specific string within a comma-separated list of strings

### View using GROUP_CONCAT()
-- Create a view (sumiCont) showing each contract code alongside
--    the list of supply IDs associated with it
CREATE VIEW sumiCont
AS
SELECT contrato_id, GROUP_CONCAT(suministro_id) AS 'Suministros relacionados'
FROM suministros
GROUP BY contrato_id;

-- Verify the view was created
SHOW TABLES;

-- View the contents of the sumiCont view
SELECT * FROM sumiCont;


### View using FIND_IN_SET()
-- Create a view (cliCDMX) showing the ID and name(s) of customers
--    located in Ciudad de México
CREATE VIEW cliCDMX
AS
SELECT cliente_id, nombre_s
FROM clientes
WHERE FIND_IN_SET(' Ciudad de México', direccion) > 0;

-- Verify the view was created
SHOW TABLES;

-- View the contents of the cliCDMX view
SELECT * FROM cliCDMX;


#############################################################################################################################
# 2 Queries using WHERE and ORDER BY clauses

### Query 1
-- Retrieve all payment records where the payment method
--    is 'Transferencia bancaria' (bank transfer),
--    ordered by amount in ascending order
SELECT *
FROM pagos
WHERE metodo_pago = 'Transferencia bancaria'
ORDER BY monto;

### Query 2
-- Retrieve all contract records where the service type
--    is 'Residencial', ordered by start date in descending order
SELECT *
FROM contratos
WHERE tipo_servicio = 'Residencial'
ORDER BY fecha_inicio DESC;


#############################################################################################################################
# 2 Queries using HAVING in combination with GROUP BY

### Query 1
-- Retrieve the maximum invoice amount grouped by status,
--    only including groups where the maximum amount exceeds 1000
SELECT estado, MAX(monto)
FROM facturas
GROUP BY estado
HAVING MAX(monto) > 1000;

### Query 2
-- Retrieve the minimum supply quantity grouped by contract ID,
--    only including groups where the minimum quantity is less than 6000
SELECT contrato_id, MIN(cantidad)
FROM suministros
GROUP BY contrato_id
HAVING MIN(cantidad) < 6000;


#############################################################################################################################
# 2 Queries using implicit JOIN (WHERE)

### Query 1
-- Retrieve all contract and customer data
--    for contracts linked to a customer
SELECT *
FROM contratos, clientes
WHERE contratos.cliente_id = clientes.cliente_id;

### Query 2
-- Retrieve all data for the first three supplies
--    along with their related contract data
SELECT *
FROM suministros, contratos
WHERE suministros.contrato_id = contratos.contrato_id
ORDER BY suministros.suministro_id
LIMIT 3;


#############################################################################################################################
# 2 Queries using explicit JOIN

### Query 1
-- Retrieve all contract data, including contracts
--    that have no associated supplies (RIGHT JOIN)
SELECT *
FROM suministros
RIGHT JOIN contratos
USING(contrato_id);

### Query 2
-- Retrieve all supply data for supplies whose
--    invoices have already been paid
SELECT *
FROM pagos
JOIN facturas
    USING(factura_id)
JOIN suministros
    USING(suministro_id)
WHERE facturas.estado = 'Pagada';


#############################################################################################################################
# 2 Queries using subqueries with single-row operators

### Query 1
-- Retrieve all contracts whose start date is earlier
--    than the start date of contract with ID = 4
SELECT *
FROM contratos
WHERE fecha_inicio < (SELECT fecha_inicio
                      FROM contratos
                      WHERE contrato_id = 4);

### Query 2
-- Retrieve all invoices whose status differs
--    from the status of invoice with ID = 2
SELECT *
FROM facturas
WHERE estado != (SELECT estado
                 FROM facturas
                 WHERE factura_id = 2);


#############################################################################################################################
# 2 Queries using subqueries with multi-row operators

### Query 1
-- Retrieve all supplies whose quantity matches
--    the maximum quantity of any contract group
SELECT *
FROM suministros
WHERE cantidad IN (SELECT MAX(cantidad)
                   FROM suministros
                   GROUP BY contrato_id);

### Query 2
-- Retrieve all payments whose amount is less than
--    every payment made via 'Transferencia bancaria' (bank transfer)
SELECT *
FROM pagos
WHERE monto < ALL (SELECT monto
                   FROM pagos
                   WHERE metodo_pago = 'Transferencia bancaria');

-- End
