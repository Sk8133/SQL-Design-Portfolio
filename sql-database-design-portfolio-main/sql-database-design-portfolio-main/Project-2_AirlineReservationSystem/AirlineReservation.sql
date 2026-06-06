-- ✅ Airline Reservation System - Final SQL File
-- Author: Anjali Shinde
-- Date: 21 July 2025

-- ==========================================
-- ✅ 1️⃣ Create Database & Use it
-- ==========================================

CREATE DATABASE IF NOT EXISTS AirlineReservation;
USE AirlineReservation;

-- ==========================================
-- ✅ 2️⃣ Drop Tables if They Exist (in correct FK order)
-- ==========================================

DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Seats;
DROP TABLE IF EXISTS Flights;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Aircrafts;
DROP TABLE IF EXISTS Airports;

-- ==========================================
-- ✅ 3️⃣ Create Tables
-- ==========================================

-- Airports Table
CREATE TABLE Airports (
    AirportID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100),
    IATA_Code CHAR(3) UNIQUE
);

-- Aircrafts Table
CREATE TABLE Aircrafts (
    AircraftID INT AUTO_INCREMENT PRIMARY KEY,
    Model VARCHAR(50),
    TotalSeats INT
);

-- Flights Table
CREATE TABLE Flights (
    FlightID INT AUTO_INCREMENT PRIMARY KEY,
    AircraftID INT,
    DepartureAirportID INT,
    ArrivalAirportID INT,
    DepartureTime DATETIME,
    ArrivalTime DATETIME,
    FOREIGN KEY (AircraftID) REFERENCES Aircrafts(AircraftID),
    FOREIGN KEY (DepartureAirportID) REFERENCES Airports(AirportID),
    FOREIGN KEY (ArrivalAirportID) REFERENCES Airports(AirportID)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);

-- Seats Table
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    AircraftID INT,
    SeatNumber VARCHAR(5),
    Class ENUM('Economy', 'Business'),
    IsBooked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (AircraftID) REFERENCES Aircrafts(AircraftID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    FlightID INT,
    SeatNumber VARCHAR(5),
    BookingDate DATETIME,
    Status ENUM('Booked', 'Cancelled'),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID)
);

-- ==========================================
-- ✅ 4️⃣ Insert Data
-- ==========================================

-- Airports
INSERT INTO Airports (AirportID, Name, City, Country, IATA_Code)
VALUES
(1, 'Mumbai International Airport', 'Mumbai', 'India', 'BOM'),
(2, 'Delhi International Airport', 'Delhi', 'India', 'DEL'),
(3, 'Bengaluru International Airport', 'Bengaluru', 'India', 'BLR');

-- Aircrafts
INSERT INTO Aircrafts (AircraftID, Model, TotalSeats)
VALUES
(1, 'Airbus A320', 180),
(2, 'Boeing 737', 160);

-- Customers
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, Phone)
VALUES
(1, 'Anjali', 'Shinde', 'anjali.shinde@example.com', '+91-9876543210'),
(2, 'Rahul', 'Verma', 'rahul.verma@example.com', '+91-9123456789');

-- Seats
INSERT INTO Seats (AircraftID, SeatNumber, Class)
VALUES
(1, '1A', 'Business'),
(1, '1B', 'Business'),
(1, '10A', 'Economy'),
(1, '10B', 'Economy'),
(2, '1A', 'Business'),
(2, '1B', 'Business'),
(2, '15A', 'Economy'),
(2, '15B', 'Economy');

-- Flights (using known IDs)
INSERT INTO Flights (AircraftID, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime)
VALUES
(1, 1, 2, '2025-07-30 09:00:00', '2025-07-30 11:30:00'),
(2, 2, 1, '2025-07-31 15:00:00', '2025-07-31 17:30:00'),
(1, 1, 3, '2025-08-01 07:00:00', '2025-08-01 09:30:00');

-- Bookings
INSERT INTO Bookings (CustomerID, FlightID, SeatNumber, BookingDate, Status)
VALUES
(1, 1, '10A', NOW(), 'Booked'),
(2, 2, '15A', NOW(), 'Booked');

-- ==========================================
-- ✅ 5️⃣ Triggers
-- ==========================================

DELIMITER $$

-- Trigger: Mark seat as booked after booking insert
CREATE TRIGGER AfterBookingInsert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
  UPDATE Seats
  SET IsBooked = TRUE
  WHERE SeatNumber = NEW.SeatNumber
    AND AircraftID = (SELECT AircraftID FROM Flights WHERE FlightID = NEW.FlightID);
END$$

-- Trigger: Mark seat as available if booking is cancelled
CREATE TRIGGER AfterBookingCancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  IF NEW.Status = 'Cancelled' THEN
    UPDATE Seats
    SET IsBooked = FALSE
    WHERE SeatNumber = NEW.SeatNumber
      AND AircraftID = (SELECT AircraftID FROM Flights WHERE FlightID = NEW.FlightID);
  END IF;
END$$

DELIMITER ;

-- ==========================================
-- ✅ 6️⃣ View: Available Seats
-- ==========================================

CREATE VIEW AvailableSeats AS
SELECT SeatID, AircraftID, SeatNumber, Class
FROM Seats
WHERE IsBooked = FALSE;

-- ==========================================
-- ✅ 7️⃣ Example Queries
-- ==========================================

-- Find available seats for Aircraft 1
SELECT * FROM AvailableSeats WHERE AircraftID = 1;

-- Search flights by date & route
SELECT 
  F.FlightID,
  A1.Name AS DepartureAirport,
  A2.Name AS ArrivalAirport,
  F.DepartureTime,
  F.ArrivalTime
FROM Flights F
JOIN Airports A1 ON F.DepartureAirportID = A1.AirportID
JOIN Airports A2 ON F.ArrivalAirportID = A2.AirportID
WHERE DATE(F.DepartureTime) = '2025-07-30'
  AND A1.City = 'Mumbai'
  AND A2.City = 'Delhi';

-- Booking summary report
SELECT 
  B.BookingID,
  C.FirstName,
  C.LastName,
  F.FlightID,
  A1.Name AS DepartureAirport,
  A2.Name AS ArrivalAirport,
  B.SeatNumber,
  B.Status,
  B.BookingDate
FROM Bookings B
JOIN Customers C ON B.CustomerID = C.CustomerID
JOIN Flights F ON B.FlightID = F.FlightID
JOIN Airports A1 ON F.DepartureAirportID = A1.AirportID
JOIN Airports A2 ON F.ArrivalAirportID = A2.AirportID;

-- ✅ END OF FILE
