/* ============================================================
   1. CREATE DATABASE
   ============================================================ */
CREATE DATABASE MeterSenseDB;
GO
USE MeterSenseDB;
GO

/* ============================================================
   2. TABLES
   ============================================================ */

-- 2.1 Customers
CREATE TABLE Customers (
    CustomerID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName    NVARCHAR(100) NOT NULL,
    PhoneNumber     NVARCHAR(20),
    AddressLine1    NVARCHAR(150),
    City            NVARCHAR(80),
    Country         NVARCHAR(80) DEFAULT 'Kenya'
);
GO

-- 2.2 Meters
CREATE TABLE Meters (
    MeterID         INT IDENTITY(1,1) PRIMARY KEY,
    MeterSerial     NVARCHAR(50) NOT NULL UNIQUE,
    CustomerID      INT NULL,
    InstallDate     DATE,
    Status          VARCHAR(20) NOT NULL CHECK (Status IN ('ACTIVE','INACTIVE','FAULTY','RETIRED')),
    SIM_ICCID       NVARCHAR(25),
    NetworkProvider NVARCHAR(30),
    FirmwareVersion NVARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- 2.3 Firmware Versions
CREATE TABLE FirmwareVersions (
    FirmwareID      INT IDENTITY(1,1) PRIMARY KEY,
    VersionCode     NVARCHAR(20) NOT NULL UNIQUE,
    ReleaseDate     DATE,
    Notes           NVARCHAR(200)
);
GO

-- 2.4 Failure Stages
CREATE TABLE FailureStages (
    FailureStageCode VARCHAR(30) PRIMARY KEY,
    Description      NVARCHAR(200)
);
GO

INSERT INTO FailureStages VALUES
('DOWNLOAD','Failed during download'),
('FLASH','Failed while flashing memory'),
('AUTO_CONFIG','Failed during auto-configuration'),
('REBOOT','Failed during reboot/startup'),
('UNKNOWN','Failure cause not classified');
GO

-- 2.5 Firmware Updates (Core KPI table)
CREATE TABLE FirmwareUpdates (
    UpdateID                INT IDENTITY(1,1) PRIMARY KEY,
    MeterID                 INT NOT NULL,
    FirmwareID              INT NOT NULL,
    RequestedAt             DATETIME2(0) NOT NULL,
    StartedAt               DATETIME2(0),
    CompletedAt             DATETIME2(0),
    Status                  VARCHAR(20) NOT NULL CHECK (Status IN ('PENDING','IN_PROGRESS','SUCCESS','FAILED','TIMEOUT')),
    FailureReason           NVARCHAR(200),
    UploadDurationSec       INT,
    AutoConfigDurationSec   INT,
    TotalProcessDurationSec AS (ISNULL(UploadDurationSec,0) + ISNULL(AutoConfigDurationSec,0)) PERSISTED,
    FailureStage            VARCHAR(30),
    FOREIGN KEY (MeterID) REFERENCES Meters(MeterID),
    FOREIGN KEY (FirmwareID) REFERENCES FirmwareVersions(FirmwareID),
    FOREIGN KEY (FailureStage) REFERENCES FailureStages(FailureStageCode)
);
GO

-- 2.6 Configuration Events
CREATE TABLE ConfigurationEvents (
    ConfigID        INT IDENTITY(1,1) PRIMARY KEY,
    MeterID         INT NOT NULL,
    EventTime       DATETIME2(0) NOT NULL,
    ConfigType      VARCHAR(50) NOT NULL,
    Details         NVARCHAR(200),
    DurationSec     INT,
    FOREIGN KEY (MeterID) REFERENCES Meters(MeterID)
);
GO

-- 2.7 Connectivity Logs
CREATE TABLE ConnectivityLogs (
    LogID           BIGINT IDENTITY(1,1) PRIMARY KEY,
    MeterID         INT NOT NULL,
    LogTime         DATETIME2(0) NOT NULL,
    SignalRSSI_dBm  INT,
    NetworkType     VARCHAR(10),
    IsConnected     BIT NOT NULL,
    ErrorCode       NVARCHAR(50),
    LinkType        VARCHAR(20) NULL
);
GO

-- 2.8 Usage Readings
CREATE TABLE UsageReadings (
    ReadingID       BIGINT IDENTITY(1,1) PRIMARY KEY,
    MeterID         INT NOT NULL,
    ReadingTime     DATETIME2(0) NOT NULL,
    GasVolume_m3    DECIMAL(10,3),
    BatteryVoltage  DECIMAL(5,2),
    Temperature_C   DECIMAL(5,2),
    FOREIGN KEY (MeterID) REFERENCES Meters(MeterID)
);
GO

-- 2.9 Indexes
CREATE INDEX IX_FirmwareUpdates_MeterID ON FirmwareUpdates (MeterID, RequestedAt);
CREATE INDEX IX_ConnLogs_MeterID_Time   ON ConnectivityLogs(MeterID, LogTime);
CREATE INDEX IX_Usage_MeterID_Time      ON UsageReadings(MeterID, ReadingTime);
GO

/* ============================================================
   3. SAMPLE DATA
   ============================================================ */

-- Customers
INSERT INTO Customers (CustomerName, PhoneNumber, AddressLine1, City) VALUES
('Alice Njeri','+254711000111','House 12, Embakasi','Nairobi'),
('Demo Site – PLANT','+254722333444','Industrial Area','Nairobi');
GO

-- Meters
INSERT INTO Meters VALUES
('MSENSE-KE-0001',1,'2024-01-15','ACTIVE','8925401234567890001','Safaricom','v1.0.0'),
('MSENSE-KE-0002',2,'2024-02-10','ACTIVE','8925401234567890002','Safaricom','v1.0.0');
GO

-- Firmware Versions
INSERT INTO FirmwareVersions VALUES
('v1.0.0','2024-01-01','Initial firmware'),
('v1.1.0','2024-03-01','Optimized retries'),
('v1.2.0','2024-05-15','Faster auto-config');
GO

-- FirmwareUpdates sample
INSERT INTO FirmwareUpdates
(MeterID,FirmwareID,RequestedAt,StartedAt,CompletedAt,Status,FailureReason,UploadDurationSec,AutoConfigDurationSec,FailureStage)
VALUES
(1,2,'2024-06-01 10:00','2024-06-01 10:00','2024-06-01 10:05','SUCCESS',NULL,120,180,NULL),
(1,3,'2024-07-01 11:00','2024-07-01 11:00','2024-07-01 11:02','SUCCESS',NULL,40,40,NULL),
(2,2,'2024-06-02 09:30','2024-06-02 09:30','2024-06-02 09:40','TIMEOUT','Network drop',120,300,'AUTO_CONFIG');
GO

-- Connectivity logs
INSERT INTO ConnectivityLogs (MeterID,LogTime,SignalRSSI_dBm,NetworkType,IsConnected,ErrorCode) VALUES
(2,'2024-06-02 09:35',-105,'4G',0,'PDP_FAIL'),
(2,'2024-06-02 09:36',-110,'4G',0,'NETWORK_TIMEOUT');
GO

-- Usage readings
INSERT INTO UsageReadings VALUES
(1,'2024-06-01 10:03',12.345,3.78,27.5),
(1,'2024-06-02 11:15',13.100,3.75,28.1),
(2,'2024-06-02 09:35',10.540,3.70,26.8);
GO

/* ============================================================
   4. CONNECTIVITY & LINK-SWITCHING LOGIC
   ============================================================ */

-- Link Types
CREATE TABLE LinkTypes (
    LinkTypeCode VARCHAR(20) PRIMARY KEY,
    Description  NVARCHAR(200)
);
GO

INSERT INTO LinkTypes VALUES
('CELLULAR','Terrestrial mobile network'),
('SATELLITE','LEO/GEO satellite link');
GO

-- Connectivity Config (Thresholds)
CREATE TABLE MeterConnectivityConfig (
    MeterID              INT PRIMARY KEY,
    PrimaryLinkType      VARCHAR(20) NOT NULL,
    SecondaryLinkType    VARCHAR(20),
    MinCellularRSSI_dBm  INT NOT NULL DEFAULT -100,
    MaxAllowedFailures   INT NOT NULL DEFAULT 3,
    PreferredSatProvider NVARCHAR(50),
    UseMLSwitching       BIT NOT NULL DEFAULT 0,
    MLThreshold_Prob     FLOAT,
    MLModelVersion       NVARCHAR(50),
    FOREIGN KEY (MeterID) REFERENCES Meters(MeterID),
    FOREIGN KEY (PrimaryLinkType) REFERENCES LinkTypes(LinkTypeCode),
    FOREIGN KEY (SecondaryLinkType) REFERENCES LinkTypes(LinkTypeCode)
);
GO

INSERT INTO MeterConnectivityConfig
(MeterID,PrimaryLinkType,SecondaryLinkType,MinCellularRSSI_dBm,MaxAllowedFailures)
VALUES
(1,'CELLULAR','SATELLITE',-100,3),
(2,'CELLULAR','SATELLITE',-95,2);
GO

-- LinkSwitchEvents
CREATE TABLE LinkSwitchEvents (
    SwitchID        INT IDENTITY(1,1) PRIMARY KEY,
    MeterID         INT NOT NULL,
    SwitchTime      DATETIME2(0) NOT NULL,
    FromLinkType    VARCHAR(20) NOT NULL,
    ToLinkType      VARCHAR(20) NOT NULL,
    Reason          NVARCHAR(200),
    PrevRSSI_dBm    INT,
    PrevFailCount   INT,
    FOREIGN KEY (MeterID) REFERENCES Meters(MeterID),
    FOREIGN KEY (FromLinkType) REFERENCES LinkTypes(LinkTypeCode),
    FOREIGN KEY (ToLinkType)   REFERENCES LinkTypes(LinkTypeCode)
);
GO

/* ============================================================
   5. MACHINE LEARNING TABLES
   ============================================================ */

-- ML Models
CREATE TABLE MLModels (
    ModelID      INT IDENTITY(1,1) PRIMARY KEY,
    ModelName    NVARCHAR(100) NOT NULL,
    ModelVersion NVARCHAR(50) NOT NULL,
    UseCase      NVARCHAR(50) NOT NULL,
    TrainedFrom  DATE,
    TrainedTo    DATE,
    MetricName   NVARCHAR(50),
    MetricValue  FLOAT,
    Notes        NVARCHAR(200)
);
GO

INSERT INTO MLModels VALUES
('Link Failure Classifier','v1.0','LINK_SWITCHING','2024-01-01','2024-06-30','AUC',0.87,'GBM model predicting failures');
GO

-- ML Predictions
CREATE TABLE LinkFailurePredictions (
    PredictionID        INT IDENTITY(1,1) PRIMARY KEY,
    UpdateID            INT NOT NULL,
    ModelID             INT NOT NULL,
    PredictionTime      DATETIME2(0) NOT NULL,
    ProbFailure         FLOAT NOT NULL,
    RecommendedLinkType VARCHAR(20),
    UsedForDecision     BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (UpdateID) REFERENCES FirmwareUpdates(UpdateID),
    FOREIGN KEY (ModelID) REFERENCES MLModels(ModelID),
    FOREIGN KEY (RecommendedLinkType) REFERENCES LinkTypes(LinkTypeCode)
);
GO

/* ============================================================
   6. VIEWS
   ============================================================ */

-- Firmware KPIs
CREATE VIEW vw_FirmwareVersionKPI AS
SELECT
    fv.VersionCode,
    COUNT(*) AS TotalUpdates,
    SUM(CASE WHEN fu.Status='SUCCESS' THEN 1 ELSE 0 END) AS SuccessfulUpdates,
    SUM(CASE WHEN fu.Status IN ('FAILED','TIMEOUT') THEN 1 ELSE 0 END) AS FailedUpdates,
    AVG(CAST(fu.UploadDurationSec AS FLOAT)) AS AvgUploadSec,
    AVG(CAST(fu.AutoConfigDurationSec AS FLOAT)) AS AvgAutoConfigSec,
    AVG(CAST(fu.TotalProcessDurationSec AS FLOAT)) AS AvgTotalProcessSec
FROM FirmwareUpdates fu
JOIN FirmwareVersions fv ON fu.FirmwareID = fv.FirmwareID
GROUP BY fv.VersionCode;
GO

-- Problem Meters
CREATE VIEW vw_ProblemMeters AS
SELECT
    m.MeterSerial,
    m.NetworkProvider,
    COUNT(*) AS TotalUpdates,
    SUM(CASE WHEN fu.Status IN ('FAILED','TIMEOUT') THEN 1 ELSE 0 END) AS FailCount,
    AVG(CAST(fu.TotalProcessDurationSec AS FLOAT)) AS AvgTotalSec
FROM FirmwareUpdates fu
JOIN Meters m ON fu.MeterID = m.MeterID
GROUP BY m.MeterSerial, m.NetworkProvider;
GO

-- Failure Root Cause (Firmware + Network)
CREATE VIEW vw_FailureRootCause AS
SELECT TOP 1000
    fu.UpdateID,
    m.MeterSerial,
    fu.Status,
    fu.FailureStage,
    fu.FailureReason,
    fu.TotalProcessDurationSec,
    cl.SignalRSSI_dBm,
    cl.NetworkType,
    cl.IsConnected,
    cl.ErrorCode
FROM FirmwareUpdates fu
JOIN Meters m ON fu.MeterID = m.MeterID
LEFT JOIN ConnectivityLogs cl
    ON fu.MeterID = cl.MeterID
    AND ABS(DATEDIFF(MINUTE, fu.CompletedAt, cl.LogTime)) <= 5
WHERE fu.Status IN ('FAILED','TIMEOUT');
GO

-- ML Prediction Performance View
CREATE VIEW vw_MLPredictionPerformance AS
SELECT
    p.PredictionID,
    fu.UpdateID,
    m.MeterSerial,
    p.ProbFailure,
    p.RecommendedLinkType,
    fu.Status AS ActualStatus,
    CASE WHEN fu.Status IN ('FAILED','TIMEOUT') THEN 1 ELSE 0 END AS ActualFailed,
    p.UsedForDecision,
    mm.ModelName,
    mm.ModelVersion
FROM LinkFailurePredictions p
JOIN FirmwareUpdates fu ON p.UpdateID = fu.UpdateID
JOIN Meters m ON fu.MeterID = m.MeterID
JOIN MLModels mm ON p.ModelID = mm.ModelID;
GO

/* ============================================================
   7. DONE
   ============================================================ */

SELECT 'MeterSenseDB Build Complete' AS Status;
GO
