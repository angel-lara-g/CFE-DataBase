/*
Database Systems II
Final Project: dbCFE
Objective: DDL and DML Script
José Ángel Lara Gómez
*/

#############################################################################################################################
# DDL

-- Create the dbCFE database
CREATE DATABASE dbCFE;

-- Use the dbCFE database
USE dbCFE;

-- Create the CLIENTES (Customers) table
CREATE TABLE CLIENTES (
    cliente_id       INT AUTO_INCREMENT,
    nombre_s         VARCHAR(50)  NOT NULL,
    apellido_paterno VARCHAR(40)  NOT NULL,
    apellido_materno VARCHAR(40),
    direccion        VARCHAR(255),
    telefono         VARCHAR(20),
    email            VARCHAR(100),
    PRIMARY KEY (cliente_id)
);

-- Create the CONTRATOS (Contracts) table
-- Each contract is linked to a customer; updates cascade, deletes are restricted
CREATE TABLE CONTRATOS (
    contrato_id   INT AUTO_INCREMENT,
    cliente_id    INT         NOT NULL,
    fecha_inicio  DATE,
    tipo_servicio VARCHAR(50),
    estado        VARCHAR(50),
    PRIMARY KEY (contrato_id),
    CONSTRAINT FOREIGN KEY (cliente_id) REFERENCES CLIENTES(cliente_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Create the SUMINISTROS (Supplies) table
-- Each supply period is linked to a contract; updates cascade, deletes are restricted
CREATE TABLE SUMINISTROS (
    suministro_id INT AUTO_INCREMENT,
    contrato_id   INT            NOT NULL,
    cantidad      DECIMAL(10, 2),
    fecha_inicio  DATE,
    fecha_corte   DATE,
    PRIMARY KEY (suministro_id),
    CONSTRAINT FOREIGN KEY (contrato_id) REFERENCES CONTRATOS(contrato_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Create the FACTURAS (Invoices) table
-- Each invoice is linked to a supply; default status is 'Pendiente' (Pending)
-- Updates cascade, deletes are restricted
CREATE TABLE FACTURAS (
    factura_id    INT AUTO_INCREMENT,
    suministro_id INT            NOT NULL,
    fecha_emision DATE,
    fecha_limite  DATE,
    monto         DECIMAL(10, 2),
    estado        VARCHAR(50)    DEFAULT 'Pendiente',
    PRIMARY KEY (factura_id),
    CONSTRAINT FOREIGN KEY (suministro_id) REFERENCES SUMINISTROS(suministro_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Create the PAGOS (Payments) table
-- Each payment is linked to an invoice; updates cascade, deletes are restricted
CREATE TABLE PAGOS (
    pago_id      INT AUTO_INCREMENT,
    factura_id   INT            NOT NULL,
    fecha_pago   DATE,
    monto        DECIMAL(10, 2),
    metodo_pago  VARCHAR(50),
    PRIMARY KEY (pago_id),
    CONSTRAINT FOREIGN KEY (factura_id) REFERENCES FACTURAS(factura_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


#############################################################################################################################
# DML

-- Use the dbCFE database
USE dbCFE;

-- Insert sample data into the CLIENTES (Customers) table
INSERT INTO CLIENTES (nombre_s, apellido_paterno, apellido_materno, direccion, telefono, email) VALUES
('Juan',   'Pérez',     'Castro',   'Calle Aurora 123, Ciudad de México',               '555-1234', 'juan.perez@gmail.com'),
('María',  'García',    'López',    'Avenida Siempre Viva 742, Monterrey',              '555-5678', 'maria.garcia@gmail.com'),
('Carlos', 'Hernández', 'Santiago', 'Boulevard de los Sueños Rotos 456, Guadalajara',  '555-8765', 'carlos.hernandez@gmail.com'),
('Luisa',  'Fernández', 'Díaz',     'Calle Primavera 789, Puebla',                     '555-4321', 'luisa.fernandez@gmail.com'),
('Ana',    'Martínez',  'Casillas', 'Avenida Reforma 100, Ciudad de México',            '555-6789', 'ana.martinez@gmail.com'),
('Pedro',  'Aguilar',   'Ponce',    'Avenida Reforma 120, Ciudad de México',            '555-6159', 'pedro.ponce@gmail.com');

-- Insert sample data into the CONTRATOS (Contracts) table
INSERT INTO CONTRATOS (cliente_id, fecha_inicio, tipo_servicio, estado) VALUES
(1, '2021-01-09', 'Residencial', 'Activo'),
(2, '2021-03-10', 'Comercial',   'Activo'),
(3, '2021-03-20', 'Residencial', 'Inactivo'),
(4, '2021-05-11', 'Industrial',  'Activo'),
(5, '2021-07-05', 'Residencial', 'Activo'),
(6, '2021-09-01', 'Residencial', 'Activo');

-- Insert sample data into the SUMINISTROS (Supplies) table
INSERT INTO SUMINISTROS (contrato_id, cantidad, fecha_inicio, fecha_corte) VALUES
(6, 1250.00,  '2024-01-02', '2024-03-01'),
(5, 1100.30,  '2024-01-06', '2024-03-05'),
(1, 1000.40,  '2024-01-10', '2024-03-09'),
(2, 6300.00,  '2024-01-11', '2024-03-10'),
(4, 65000.75, '2024-01-12', '2024-03-11'),
(6, 1200.00,  '2024-03-02', '2024-05-01'),
(5, 1000.50,  '2024-03-06', '2024-05-05'),
(1, 1100.25,  '2024-03-10', '2024-05-09'),
(2, 6500.00,  '2024-03-11', '2024-05-10'),
(4, 61400.10, '2024-03-12', '2024-05-11');

-- Insert sample data into the FACTURAS (Invoices) table
-- Invoices marked DEFAULT use the column's default status: 'Pendiente'
INSERT INTO FACTURAS (suministro_id, fecha_emision, fecha_limite, monto, estado) VALUES
(1,  '2024-03-01', '2024-03-17', 743.75,   'Pagada'),
(2,  '2024-03-05', '2024-03-21', 660.18,   'Pagada'),
(3,  '2024-03-09', '2024-03-25', 600.24,   'Pagada'),
(4,  '2024-03-10', '2024-03-26', 3780.00,  'Pagada'),
(5,  '2024-03-11', '2024-03-27', 39000.45, 'Pagada'),
(6,  '2024-05-01', '2024-05-17', 714.00,   DEFAULT),
(7,  '2024-05-05', '2024-05-21', 600.30,   'Pagada'),
(8,  '2024-05-09', '2024-05-25', 660.15,   'Pagada'),
(9,  '2024-05-10', '2024-05-26', 3900.00,  DEFAULT),
(10, '2024-05-11', '2024-05-27', 36840.06, DEFAULT);

-- Insert sample data into the PAGOS (Payments) table
-- Note: invoices 6, 9, and 10 are not fully paid yet
INSERT INTO PAGOS (factura_id, fecha_pago, monto, metodo_pago) VALUES
(1, '2024-03-13', 743.75,   'Efectivo'),
(2, '2024-03-15', 660.18,   'Transferencia bancaria'),
(3, '2024-03-16', 600.24,   'Efectivo'),
(4, '2024-03-21', 3780.00,  'Tarjeta de crédito'),
(5, '2024-03-23', 39000.45, 'Tarjeta de crédito'),
(7, '2024-05-14', 600.30,   'Transferencia bancaria'),
(8, '2024-05-15', 660.15,   'Efectivo'),
(9, '2024-05-18', 3100.00,  'Tarjeta de crédito');
