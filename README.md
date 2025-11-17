# MeterSense – Smart LPG Meter Analytics & ML-Driven Connectivity Platform

MeterSense is a complete **end-to-end smart meter analytics system** designed to monitor
and optimize the performance of LPG smart meters.  
It was inspired by operational challenges observed in large-scale deployments
(e.g., long auto-configuration times, inconsistent firmware behavior, and unstable
network connectivity in low-signal regions).

This repository contains the **complete SQL Server schema**, sample datasets,
ML-ready tables, link-switching logic, and system performance views.

---

## 🚀 Features

### **1. Firmware Update Analytics**
- Tracks upload time, flashing, auto-configuration, and total process duration  
- Identifies slow versions, failing meters, and firmware performance trends  
- Includes KPIs, version-level performance views, and root-cause breakdowns

### **2. Connectivity Monitoring**
- Logs signal RSSI, network type, error codes, and link health  
- Supports hybrid connectivity (CELLULAR + SATELLITE)  
- Threshold-based and ML-based recommendations for link switching

### **3. Machine Learning Integration**
- Stores ML models, metadata, training windows, and evaluation metrics  
- Prediction table for failure probability per update  
- ML threshold control per meter (e.g., switch if `ProbFailure ≥ 0.7`)  
- View for real-time ML prediction performance evaluation

### **4. Link-Switching Logic**
- Supports cellular → satellite switching when:
  - Signal is below threshold  
  - Repeated failures occur  
  - ML predicts high probability of failure  
- Event log records switching reason, previous failures, and RSSI

### **5. Highly Normalized SQL Schema**
- Customers  
- Meters  
- Firmware Versions  
- Firmware Updates  
- Connectivity Logs  
- Usage Readings  
- Auto-Configuration Events  
- ML Models & Predictions  
- Link Types  
- Link Switch Events  
- Threshold tables for decision-making  

---

## 🏗️ System Architecture Overview

### **Database Layer (SQL Server)**  
Contains 25+ tables, indexes, and materialized views for analytics.

**Core tables include:**
- `FirmwareUpdates`
- `ConnectivityLogs`
- `UsageReadings`
- `Meters`, `Customers`
- `MLModels`, `LinkFailurePredictions`
- `MeterConnectivityConfig`
- `LinkSwitchEvents`

**Views include:**
- `vw_FirmwareVersionKPI`  
- `vw_ProblemMeters`  
- `vw_FailureRootCause`  
- `vw_MLPredictionPerformance`

---

## 📊 What This System Can Do

### Identify:
- Slow-performing meters  
- Problematic firmware releases  
- Timeouts caused by weak signal or network drops  
- Firmware improvements across versions  
- Meters that need satellite fallback  

### Predict:
- Probability that a firmware update will fail  
- Whether the system should switch from CELLULAR to SATELLITE  
- Long-term meter reliability  
