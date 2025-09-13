# Clinic Booking System Database – README

## Project Objective
The goal of this project is to **design and implement a full-featured relational database** using MySQL for a clinic environment. The database supports:

- Patient management  
- Doctor scheduling  
- Appointments and consultations  
- Prescriptions and medications  
- Billing and payments  
- Staff management  
- Lab tests and results  

This aligns with the assignment instructions: a **real-world use case**, **well-structured tables**, proper **constraints**, and **relationships**.

---

## Database Overview

### 1. Database Name
```sql
CREATE DATABASE ClinicDB;
USE ClinicDB;

| Table                       | Purpose                                                 | Key Relationships                                                              |
| --------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------ |
| **Patients**                | Stores patient personal details                         | `PatientID` is PK, linked to `Appointments`, `Invoices`                        |
| **Doctors**                 | Stores doctor personal info                             | `DoctorID` is PK, linked to `Appointments`, `DoctorSchedules`, `DoctorTimeOff` |
| **Specialties**             | Doctor specialties                                      | `SpecialtyID` is PK, linked to `Doctors`                                       |
| **Rooms**                   | Clinic rooms for appointments                           | `RoomID` is PK, linked to `Appointments` and `StaffAssignments`                |
| **Appointments**            | Links patients to doctors, rooms, and schedules         | `AppointmentID` is PK, FKs to `Patients`, `Doctors`, `Rooms`                   |
| **Medications**             | Master list of drugs                                    | `MedicationID` is PK, linked via `PrescriptionMedications`                     |
| **Prescriptions**           | One per appointment                                     | `PrescriptionID` is PK, FK to `Appointments`                                   |
| **PrescriptionMedications** | Many-to-many link between prescriptions and medications | Composite PK (`PrescriptionID`, `MedicationID`)                                |
| **Invoices**                | Billing records                                         | `InvoiceID` is PK, FKs to `Patients` and optionally `Appointments`             |
| **InvoiceItems**            | Line items for invoices                                 | FK to `Invoices`                                                               |
| **Payments**                | Tracks payments against invoices                        | FK to `Invoices`                                                               |
| **Staff**                   | Non-doctor employees                                    | `StaffID` is PK, can be assigned to rooms via `StaffAssignments`               |
| **StaffAssignments**        | Staff room or duty assignments                          | FKs to `Staff` and `Rooms`                                                     |
| **LabTests**                | Master list of lab tests                                | `LabTestID` is PK, linked via `LabOrderItems`                                  |
| **LabOrders**               | Lab tests ordered per appointment                       | `LabOrderID` is PK, FK to `Appointments`                                       |
| **LabOrderItems**           | Many-to-many link between lab orders and tests          | Composite PK (`LabOrderID`, `LabTestID`)                                       |
| **LabResults**              | Stores test results per order                           | FKs to `LabOrderItems`                                                         |
| **DoctorSchedules**         | Weekly availability                                     | `DoctorID` FK, defines days and times                                          |
| **DoctorTimeOff**           | Specific unavailable dates                              | `DoctorID` FK                                                                  |

3. Key Design Principles

Normalization

All tables follow 1NF, 2NF, and 3NF rules.

No repeated groups, partial dependencies, or transitive dependencies.

Primary Keys (PK)

Each table has a unique identifier (e.g., PatientID, DoctorID).

Foreign Keys (FK)

Maintain referential integrity between related tables.

Example: Appointments.PatientID references Patients.PatientID.

Unique & Not Null Constraints

Ensure data integrity for fields like Email, Phone, and RoomNumber.

Many-to-Many Relationships

Handled via join tables:

PrescriptionMedications

LabOrderItems

Status & Enum Fields

Used for fields with fixed options, e.g., Appointment.Status, Invoice.Status, LabOrders.Status.

4. Sample Data & Testing

Patients: 5+ sample patients with contact info and DOB

Doctors: 5+ doctors with specialties

Rooms: 5+ rooms for appointments

Appointments: Scheduled appointments linking patients to doctors/rooms

Prescriptions & Medications: Example prescriptions with dosage and duration

Invoices & Payments: Billing workflow with line items and payments

Lab Tests & Results: Orders with linked tests and sample results

Staff & Assignments: Receptionists, nurses, lab technicians assigned to rooms

Doctor Schedules & Time Off: Weekly availability and exceptions

Verification queries include:
SELECT * FROM Patients;
-- Full join query to see patient → appointment → prescription → medication
SELECT p.PatientID, CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
       a.AppointmentID, d.DoctorID, CONCAT(d.FirstName,' ',d.LastName) AS DoctorName,
       pr.PrescriptionID, m.Name AS MedicationName
FROM Patients p
JOIN Appointments a ON p.PatientID = a.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
LEFT JOIN PrescriptionMedications pm ON pr.PrescriptionID = pm.PrescriptionID
LEFT JOIN Medications m ON pm.MedicationID = m.MedicationID;
5. Implementation Highlights

All relationships enforced with FKs

ON DELETE/ON UPDATE rules applied for cascading and maintaining historical data

ENUM and default values used for statuses (appointments, invoices, lab orders)

Sample inserts provide realistic data for testing queries

6. Deliverables

SQL file containing:

CREATE DATABASE Clinic_db;

CREATE TABLE statements with constraints

Sample inserts for all tables

README (this file) explaining the design, tables, relationships, and testing.

7. How it Meets Assignment Instructions

Real-world use case: Clinic Booking System

Relational schema: all tables normalized, proper PKs and FKs

Relationships implemented: One-to-One, One-to-Many, Many-to-Many

Constraints applied: NOT NULL, UNIQUE, ENUM, AUTO_INCREMENT

Database ready for querying, testing, and further expansion (e.g., reports, dashboards)
