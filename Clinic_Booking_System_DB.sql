-- 1. Create clinic database
CREATE DATABASE IF NOT EXISTS clinic_db

-- 2. Patients table: stores clinic patients
USE clinic_db;

CREATE TABLE Patients (
  PatientID INT AUTO_INCREMENT PRIMARY KEY,   -- unique patient id
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(100) NOT NULL,
  DateOfBirth DATE NOT NULL,
  Gender ENUM('Male', 'Female', 'Other') NOT NULL,
  Phone VARCHAR(20) UNIQUE,
  Email VARCHAR(255) UNIQUE,
  Address TEXT
) ENGINE=InnoDB;

-- Specialties table
CREATE TABLE Specialties (
  SpecialtyID INT AUTO_INCREMENT PRIMARY KEY,
  SpecialtyName VARCHAR(100) NOT NULL UNIQUE
);

-- Doctors table
CREATE TABLE Doctors (
  DoctorID INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(100) NOT NULL,
  Phone VARCHAR(20) UNIQUE,
  Email VARCHAR(255) UNIQUE,
  SpecialtyID INT,
  FOREIGN KEY (SpecialtyID) REFERENCES Specialties(SpecialtyID)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- Rooms (where appointment happens)
CREATE TABLE Rooms (
  RoomID INT AUTO_INCREMENT PRIMARY KEY,
  RoomNumber VARCHAR(20) NOT NULL UNIQUE,
  Floor INT
);

-- Appointments
CREATE TABLE Appointments (
  AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
  PatientID INT NOT NULL,
  DoctorID INT NOT NULL,
  RoomID INT,
  AppointmentDateTime DATETIME NOT NULL,
  Reason TEXT,
  Status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
  FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE,
  FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) ON DELETE SET NULL
);

-- Medications
CREATE TABLE Medications (
  MedicationID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL UNIQUE,
  Description TEXT
);

-- Prescriptions (1:1 with appointment)
CREATE TABLE Prescriptions (
  PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
  AppointmentID INT UNIQUE, -- one prescription per appointment
  Notes TEXT,
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- Join table for prescriptions ↔ medications
CREATE TABLE PrescriptionMedications (
  PrescriptionID INT NOT NULL,
  MedicationID INT NOT NULL,
  Dosage VARCHAR(50),
  Duration VARCHAR(50),
  PRIMARY KEY (PrescriptionID, MedicationID),
  FOREIGN KEY (PrescriptionID) REFERENCES Prescriptions(PrescriptionID) ON DELETE CASCADE,
  FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID) ON DELETE CASCADE
);

-- insert values into Patients Table
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, Phone, Email, Address)
VALUES
('John', 'Doe', '1990-05-15', 'Male', '08012345678', 'john.doe@email.com', '12 Broad Street, Lagos'),
('Mary', 'Johnson', '1985-10-22', 'Female', '08023456789', 'mary.j@email.com', '45 Kingsway Road, Lagos'),
('Ahmed', 'Musa', '1992-03-08', 'Male', '08034567890', 'ahmed.musa@email.com', '22 Ahmadu Bello Way, Abuja'),
('Chinwe', 'Okafor', '1998-07-30', 'Female', '08045678901', 'chinwe.okafor@email.com', '78 Aba Road, Port Harcourt'),
('David', 'Smith', '1975-12-11', 'Male', '08056789012', 'david.smith@email.com', '10 Marina, Lagos');

-- Check inserted values
SELECT * FROM Patients;

-- Insert Doctor specializations 
INSERT INTO Specialties (SpecialtyName) VALUES
('Cardiology'),
('Pediatrics'),
('Dermatology'),
('Neurology'),
('General Practice');

-- Check inserted specialties and their IDs
SELECT * FROM Specialties;

-- Insert doctors referencing the SpecialtyID values (adjust IDs if your SELECT returned different ones)
INSERT INTO Doctors (FirstName, LastName, Phone, Email, SpecialtyID)
VALUES
('Emeka', 'Obi', '07011112222', 'emeka.obi@clinic.com', 1),  -- Cardiology
('Sarah', 'Brown', '07022223333', 'sarah.brown@clinic.com', 2), -- Pediatrics
('Bola', 'Adeyemi', '07033334444', 'bola.adeyemi@clinic.com', 3), -- Dermatology
('Michael', 'Johnson', '07044445555', 'michael.johnson@clinic.com', 4), -- Neurology
('Aisha', 'Mohammed', '07055556666', 'aisha.mohammed@clinic.com', 5); -- General Practice
-- Check inserted values
SELECT * FROM Doctors;

--insert values to Rooms Table
INSERT INTO Rooms (RoomNumber, Floor)
VALUES
('101A', 1),
('102B', 1),
('201A', 2),
('202B', 2),
('301A', 3);

--check inserted values
SELECT * FROM Rooms;

-- insert values into the Appointments Table
INSERT INTO Appointments (PatientID, DoctorID, RoomID, AppointmentDateTime, Reason, Status)
VALUES
(4, 4, 3, '2025-09-23 11:15:00', 'Neurology consultation', 'Scheduled'),
(5, 5, 5, '2025-09-24 15:00:00', 'General health check-up', 'Completed'),
(2, 1, 2, '2025-09-25 09:30:00', 'Follow-up on chest pain', 'Scheduled'),
(1, 2, 4, '2025-09-25 16:00:00', 'Child vaccination appointment', 'Completed'),
(3, 3, 1, '2025-09-26 10:45:00', 'Dermatology review', 'Cancelled'),
(5, 4, 2, '2025-09-27 13:00:00', 'Neurology MRI review', 'Scheduled'),
(4, 2, 3, '2025-09-28 08:30:00', 'Child fever check-up', 'Scheduled'),
(1, 5, 1, '2025-09-28 14:30:00', 'General Practitioner consultation', 'Completed'),
(3, 1, 5, '2025-09-29 11:00:00', 'Cardiology blood pressure review', 'Scheduled'),
(2, 4, 4, '2025-09-30 15:45:00', 'Migraine management consultation', 'Scheduled');

-- To verify the schedules
SELECT * FROM Appointments ORDER BY AppointmentDateTime;

-- a more detailed schedule with patient names + doctor names + room numbers
  a.AppointmentID,
  CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
  CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
  r.RoomNumber,
  a.AppointmentDateTime,
  a.Reason,
  a.Status
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Rooms r ON a.RoomID = r.RoomID
ORDER BY a.AppointmentDateTime;

-- Insert sample medications into Medications table
INSERT INTO Medications (Name, Description)
VALUES
('Amoxicillin', 'Antibiotic used to treat bacterial infections'),
('Ibuprofen', 'NSAID for pain relief, inflammation, and fever'),
('Paracetamol', 'Pain reliever and fever reducer'),
('Metformin', 'Used to control blood sugar in type 2 diabetes'),
('Lisinopril', 'ACE inhibitor for high blood pressure and heart conditions');

-- Insert prescriptions (linked 1:1 to appointments)
-- Example: AppointmentID 1 gets a prescription
INSERT INTO Prescriptions (AppointmentID, Notes)
VALUES
(1, 'Patient diagnosed with bacterial infection, prescribed antibiotics'),
(2, 'Mild fever and body aches, prescribed paracetamol and ibuprofen'),
(3, 'Routine checkup, prescribed ongoing medication for diabetes'),
(4, 'Hypertension follow-up, continue blood pressure medication');

-- Link prescriptions to medications in PrescriptionMedications
-- PrescriptionID 1 → Amoxicillin
INSERT INTO PrescriptionMedications (PrescriptionID, MedicationID, Dosage, Duration)
VALUES
(1, 1, '500mg', '7 days'),

-- PrescriptionID 2 → Paracetamol + Ibuprofen
(2, 3, '500mg every 6 hours', '3 days'),
(2, 2, '200mg every 8 hours', '3 days'),

-- PrescriptionID 3 → Metformin
(3, 4, '500mg twice daily', '30 days'),

-- PrescriptionID 4 → Lisinopril
(4, 5, '10mg once daily', '30 days');

-- Check all medications
SELECT * FROM Medications;

-- Check all prescriptions
SELECT * FROM Prescriptions;

-- Check which medications are linked to which prescriptions
SELECT * FROM PrescriptionMedications;

-- Full joined view: Patient, Appointment, Prescription, Medication details
SELECT 
    p.PatientID,
    p.FirstName AS PatientFirstName,
    p.LastName AS PatientLastName,
    a.AppointmentID,
    a.AppointmentDate,
    pr.PrescriptionID,
    pr.Notes AS PrescriptionNotes,
    m.Name AS MedicationName,
    pm.Dosage,
    pm.Duration
FROM Patients p
JOIN Appointments a ON p.PatientID = a.PatientID
JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
JOIN PrescriptionMedications pm ON pr.PrescriptionID = pm.PrescriptionID
JOIN Medications m ON pm.MedicationID = m.MedicationID
ORDER BY p.PatientID, a.AppointmentDate;

-- Full clinic view with all patient status, even if no appointment or prescription yet
SELECT 
    p.PatientID,
    p.FirstName AS PatientFirstName,
    p.LastName AS PatientLastName,
    a.AppointmentID,
    a.AppointmentDateTime,
    pr.PrescriptionID,
    pr.Notes AS PrescriptionNotes,
    m.Name AS MedicationName,
    pm.Dosage,
    pm.Duration,
    -- Status column to explain what's missing
    CASE 
        WHEN a.AppointmentID IS NULL THEN 'No Appointment'
        WHEN pr.PrescriptionID IS NULL THEN 'Appointment Without Prescription'
        WHEN pm.MedicationID IS NULL THEN 'Prescription Without Medications'
        ELSE 'Complete Record'
    END AS PatientStatus
FROM Patients p
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
LEFT JOIN PrescriptionMedications pm ON pr.PrescriptionID = pm.PrescriptionID
LEFT JOIN Medications m ON pm.MedicationID = m.MedicationID
ORDER BY p.PatientID, a.AppointmentDateTime;


-- TIME TO LEVEL UP MY CLINIC BOOKING SYSTEM

-- Add Billing & Payments system

-- Invoices: one invoice per appointment or per patient billing event
CREATE TABLE IF NOT EXISTS Invoices (
  InvoiceID INT AUTO_INCREMENT PRIMARY KEY,            -- unique invoice id
  AppointmentID INT NULL,                              -- link to appointment
  PatientID INT NOT NULL,                              -- which patient is billed
  InvoiceDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, -- when invoice was created
  TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0.00,     -- total billed
  Status ENUM('Unpaid','Partially Paid','Paid','Cancelled') NOT NULL DEFAULT 'Unpaid', -- invoice status
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE SET NULL, -- keep history
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE RESTRICT
) ENGINE=InnoDB;

--  Billing sample data
-- Insert invoice for AppointmentID 
INSERT INTO Invoices (AppointmentID, PatientID, TotalAmount, Status)
VALUES
(1, 1, 150.00, 'Unpaid'),
(2, 2, 75.00, 'Paid'),
(NULL, 5, 200.00, 'Unpaid'); -- patient billed without appointment (e.g., package)


-- Payments: payments applied to invoices (one invoice can have many payments)
CREATE TABLE IF NOT EXISTS Payments (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,            -- payment id
  InvoiceID INT NOT NULL,                              -- which invoice is being paid
  PaidAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- when payment occurred
  Amount DECIMAL(12,2) NOT NULL,                       -- amount paid
  Method ENUM('Cash','Card','Transfer','Insurance') NOT NULL, -- payment method
  TransactionRef VARCHAR(255),                         -- optional transaction reference
  FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Partial payment example
INSERT INTO Payments (InvoiceID, Amount, Method, TransactionRef)
VALUES
(2, 75.00, 'Card', 'TXN-0001');  -- pays invoice 2 fully

-- Simple invoice line items (optional; break invoice into services)
CREATE TABLE IF NOT EXISTS InvoiceItems (
  InvoiceItemID INT AUTO_INCREMENT PRIMARY KEY,        -- line id
  InvoiceID INT NOT NULL,                              -- which invoice
  Description VARCHAR(255) NOT NULL,                   -- service description
  Quantity INT NOT NULL DEFAULT 1,
  UnitPrice DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Invoice items linked to the first invoice
INSERT INTO InvoiceItems (InvoiceID, Description, Quantity, UnitPrice)
VALUES
(1, 'Consultation Fee', 1, 100.00),
(1, 'Antibiotic (Amoxicillin)', 1, 50.00),
(2, 'GP Consultation', 1, 75.00);




-- What is a hospital without Staff / Admins

-- Staff: non-doctor employees (receptionists, nurses, admins)
CREATE TABLE IF NOT EXISTS Staff (
  StaffID INT AUTO_INCREMENT PRIMARY KEY,              -- staff id
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(100) NOT NULL,
  Role VARCHAR(100) NOT NULL,                          -- e.g., Receptionist, Nurse, Admin
  Phone VARCHAR(20) UNIQUE,
  Email VARCHAR(255) UNIQUE,
  IsActive BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- Staff data
INSERT INTO Staff (FirstName, LastName, Role, Phone, Email)
VALUES
('Rita', 'Chukwu', 'Receptionist', '07088889999', 'rita.chukwu@clinic.com'),
('Nneka', 'Ibe', 'Nurse', '07077776666', 'nneka.ibe@clinic.com'),
('Tunde', 'Adebayo', 'Lab Technician', '07066665555', 'tunde.adebayo@clinic.com');

--  mapping staff to rooms or duties (simple example)
CREATE TABLE IF NOT EXISTS StaffAssignments (
  AssignmentID INT AUTO_INCREMENT PRIMARY KEY,         -- assignment id
  StaffID INT NOT NULL,
  RoomID INT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE NULL,
  FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE,
  FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Assign staff to rooms
INSERT INTO StaffAssignments (StaffID, RoomID, StartDate)
VALUES
(1, 1, '2025-01-01'),
(2, 2, '2025-01-01'),
(3, 5, '2025-03-01');


-- Add Lab Tests & Results

-- LabTests: master list of possible tests
CREATE TABLE IF NOT EXISTS LabTests (
  LabTestID INT AUTO_INCREMENT PRIMARY KEY,            -- test id
  TestCode VARCHAR(50) NOT NULL UNIQUE,                -- e.g., CBC, LFT
  TestName VARCHAR(150) NOT NULL,                      -- e.g., Complete Blood Count
  Description TEXT
) ENGINE=InnoDB;

-- Lab tests & orders
INSERT INTO LabTests (TestCode, TestName, Description)
VALUES
('CBC', 'Complete Blood Count', 'WBC, RBC, Hemoglobin count'),
('LFT', 'Liver Function Test', 'ALT, AST, Bilirubin measurements'),
('BMP', 'Basic Metabolic Panel', 'Electrolytes, renal function');

-- LabOrders: tests ordered for an appointment (one order can include many tests)
CREATE TABLE IF NOT EXISTS LabOrders (
  LabOrderID INT AUTO_INCREMENT PRIMARY KEY,           -- order id
  AppointmentID INT NOT NULL,                          -- which appointment requested labs
  OrderedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Status ENUM('Ordered','Sample Collected','Completed','Cancelled') DEFAULT 'Ordered',
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create a lab order for AppointmentID 1 and AppointmentID 2
INSERT INTO LabOrders (AppointmentID, Status) VALUES (1, 'Ordered'), (2, 'Sample Collected');

-- LabOrderItems: which tests are in a lab order
CREATE TABLE IF NOT EXISTS LabOrderItems (
  LabOrderID INT NOT NULL,
  LabTestID INT NOT NULL,
  PRIMARY KEY (LabOrderID, LabTestID),
  FOREIGN KEY (LabOrderID) REFERENCES LabOrders(LabOrderID) ON DELETE CASCADE,
  FOREIGN KEY (LabTestID) REFERENCES LabTests(LabTestID) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Link tests to orders (find LabOrderIDs — assuming they are 1 and 2)
INSERT INTO LabOrderItems (LabOrderID, LabTestID) VALUES
(1, 1), -- CBC for order 1
(1, 2), -- LFT for order 1
(2, 1); -- CBC for order 2

-- LabResults: results for each LabOrderItem (keeps results per test)
CREATE TABLE IF NOT EXISTS LabResults (
  LabResultID INT AUTO_INCREMENT PRIMARY KEY,          -- result id
  LabOrderID INT NOT NULL,
  LabTestID INT NOT NULL,
  ResultValue VARCHAR(255),                            -- free-form; could be numeric/text
  Units VARCHAR(50),
  ReferenceRange VARCHAR(100),
  ReportedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (LabOrderID, LabTestID) REFERENCES LabOrderItems(LabOrderID, LabTestID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Insert results for LabOrder 1 CBC
INSERT INTO LabResults (LabOrderID, LabTestID, ResultValue, Units, ReferenceRange)
VALUES
(1, 1, 'Hemoglobin 13.5', 'g/dL', '12-16'),
(1, 2, 'ALT 35', 'U/L', '0-40');

-- Check Doctor Schedule & Availability

-- DoctorSchedules: regular weekly availability (e.g., Mon 09:00-17:00)
CREATE TABLE IF NOT EXISTS DoctorSchedules (
  ScheduleID INT AUTO_INCREMENT PRIMARY KEY,           -- schedule id
  DoctorID INT NOT NULL,
  Weekday ENUM('Mon','Tue','Wed','Thu','Fri','Sat','Sun') NOT NULL, -- which day of week
  StartTime TIME NOT NULL,                             -- start time (e.g., '09:00:00')
  EndTime TIME NOT NULL,                               -- end time (e.g., '17:00:00')
  FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Doctor Schedules & Time Off
INSERT INTO DoctorSchedules (DoctorID, Weekday, StartTime, EndTime)
VALUES
(1, 'Mon', '09:00:00', '17:00:00'),
(1, 'Wed', '09:00:00', '17:00:00'),
(2, 'Tue', '10:00:00', '16:00:00'),
(3, 'Mon', '08:00:00', '14:00:00'),
(4, 'Thu', '09:00:00', '15:00:00');

-- DoctorTimeOff: specific date ranges when doctor is not available (vacation, training)
CREATE TABLE IF NOT EXISTS DoctorTimeOff (
  TimeOffID INT AUTO_INCREMENT PRIMARY KEY,            -- id
  DoctorID INT NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE NOT NULL,
  Reason VARCHAR(255),
  FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO DoctorTimeOff (DoctorID, StartDate, EndDate, Reason)
VALUES
(1, '2025-12-24', '2025-12-31', 'Holiday'),
(3, '2025-11-10', '2025-11-12', 'Conference');


-- Quick verification queries


-- Check invoices with payments and items
SELECT i.*, p.PaidAt, p.Amount AS LastPayment
FROM Invoices i
LEFT JOIN Payments p ON i.InvoiceID = p.InvoiceID
ORDER BY i.InvoiceID;

-- View lab orders with results
SELECT lo.LabOrderID, a.AppointmentID, p.PatientID, CONCAT(p.FirstName,' ',p.LastName) AS PatientName,
       lt.TestCode, lt.TestName, lr.ResultValue, lr.ReportedAt
FROM LabOrders lo
JOIN Appointments a ON lo.AppointmentID = a.AppointmentID
JOIN Patients p ON a.PatientID = p.PatientID
JOIN LabOrderItems li ON lo.LabOrderID = li.LabOrderID
JOIN LabTests lt ON li.LabTestID = lt.LabTestID
LEFT JOIN LabResults lr ON li.LabOrderID = lr.LabOrderID AND li.LabTestID = lr.LabTestID
ORDER BY lo.LabOrderID;

-- Show all doctors with their weekly schedule and status
SELECT 
    d.DoctorID, 
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,   -- full doctor name
    ds.Weekday,                                           -- day of the week from schedule
    ds.StartTime,                                        -- schedule start time
    ds.EndTime,                                          -- schedule end time

    -- Status column: shows 'No Schedule' if no schedule exists, else 'Has Schedule'
    CASE 
        WHEN ds.DoctorID IS NULL THEN 'No Schedule'
        ELSE 'Has Schedule'
    END AS ScheduleStatus
FROM Doctors d
LEFT JOIN DoctorSchedules ds 
    ON ds.DoctorID = d.DoctorID                            -- left join keeps all doctors
ORDER BY 
    d.DoctorID,                                           -- order by doctor id
    FIELD(ds.Weekday,'Mon','Tue','Wed','Thu','Fri','Sat','Sun'); 

