# CFE-DataBase 🔌

A relational database project modelling the core operations of the CFE (Comisión Federal de Electricidad), Mexico's federal electricity commission. The database manages customers, contracts, energy supply periods, invoices, and payments, including automated status updates via triggers and stored routines.

> Developed as a final project for the Database Systems II course at Universidad de Guadalajara — CUCEA.

---

## Technologies

- **MySQL** — relational database engine
- **SQL** — DDL, DML, QL, stored procedures, stored functions, and triggers

---

## Features

- Full relational schema with 5 tables: `CLIENTES`, `CONTRATOS`, `SUMINISTROS`, `FACTURAS`, `PAGOS`
- Foreign key constraints with cascading updates and restricted deletes
- Sample data covering residential, commercial, and industrial service types
- Views using `GROUP_CONCAT()` and `FIND_IN_SET()` predefined functions
- Queries using `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, implicit and explicit `JOIN`, and single/multi-row subqueries
- Stored procedure `PA_estadoFact` — returns invoice count and earliest due date by status
- Stored function `FA_facA` — marks a single invoice as overdue if past its due date
- Stored procedure `PA_facAtrasadas` — iterates invoices and updates overdue statuses in bulk
- Stored function `FA_sumPagos` — calculates whether an invoice has been fully paid
- `AFTER INSERT` trigger `AIpagos` — automatically updates invoice status when a payment is inserted

---

## Database Schema

```
CLIENTES (cliente_id, nombre_s, apellido_paterno, apellido_materno, direccion, telefono, email)
    │
    └── CONTRATOS (contrato_id, cliente_id, fecha_inicio, tipo_servicio, estado)
            │
            └── SUMINISTROS (suministro_id, contrato_id, cantidad, fecha_inicio, fecha_corte)
                    │
                    └── FACTURAS (factura_id, suministro_id, fecha_emision, fecha_limite, monto, estado)
                            │
                            └── PAGOS (pago_id, factura_id, fecha_pago, monto, metodo_pago)
```

---

## Project Structure

```
CFE-DataBase/
│
├── SBDII_PF_DDL_DML_dbCFE.sql   # Schema creation and sample data
├── SBDII_PF_QL_dbCFE.sql        # Views and queries
├── SBDII_PF_Progra_dbCFE.sql    # Stored procedures, functions, and trigger
├── SBDII_PF_Doc_dbCFE.pdf       # Full project documentation (Spanish)
└── README.md
```

---

## Running the Project

### Prerequisites

- MySQL 8.0 or later
- A MySQL client such as MySQL Workbench, DBeaver, or the MySQL CLI

### Execution Order

Scripts must be run in this order, as each one depends on the previous:

```bash
# 1. Create the schema and insert sample data
source SBDII_PF_DDL_DML_dbCFE.sql

# 2. Create views and run queries
source SBDII_PF_QL_dbCFE.sql

# 3. Create stored procedures, functions, and the trigger
source SBDII_PF_Progra_dbCFE.sql
```

> **Note:** `SBDII_PF_Progra_dbCFE.sql` must be run after `SBDII_PF_DDL_DML_dbCFE.sql` since the programming objects depend on the tables and data being present. Within the programming script itself, objects must also be created in the order they appear, as `FA_facA()` is required by `PA_facAtrasadas()`.

---

## Invoice Status Flow

```
Pendiente (Pending)  →  Pagada (Paid)      [when total payments ≥ amount due]
Pendiente (Pending)  →  Atrasada (Overdue) [when due date has passed]
```

---

