# MeterSense – Smart LPG Meter Analytics & ML Connectivity Platform

MeterSense is an end-to-end SQL Server–based analytics platform designed for monitoring, diagnosing, and optimizing the performance of smart LPG meters deployed in the field.

It provides insights on:
- Firmware update performance  
- Auto-configuration time  
- Network reliability  
- Failure root causes  
- Hybrid link-switching (Cellular/Satellite)  
- ML-based failure prediction  

---

## 🚀 Key Features

### 🔧 Firmware Analytics
- Track upload, flashing, and auto-configuration time  
- Compute total update duration  
- View success/failure distribution  
- Identify slow firmware versions  
- Compare performance across releases  

### 📡 Connectivity Monitoring
- Capture RSSI (signal strength), network type, errors  
- Detect weak-signal periods linked to failures  
- Understand failure patterns around update windows  
- Support for dual connectivity (CELLULAR + SATELLITE)

### 🤖 Machine Learning Integration
- Store ML models, versions, metrics, training windows  
- Predict firmware-update failure probability  
- Recommend link type based on risk  
- ML-based decision thresholds on a per-meter basis  
- Evaluate model vs real outcomes

### 🔀 Link Switching Logic
Switch between CELLULAR ↔ SATELLITE when:
- Signal RSSI drops below threshold  
- Repeated failures occur  
- ML predicts high failure risk  
- Manual override is applied  

All switching events are logged with:
- Reason  
- Previous failures  
- Previous RSSI  
- From/To link type  

---

## 🧱 Database Architecture

### Core Tables
| Table | Purpose |
|------|---------|
| `Customers` | Customer/site registry |
| `Meters` | Physical LPG meters |
| `FirmwareVersions` | Firmware releases |
| `FirmwareUpdates` | Full update lifecycle logs |
| `ConnectivityLogs` | Network quality + errors |
| `ConfigurationEvents` | Auto-config or overrides |
| `UsageReadings` | Gas, battery, temperature |
| `MLModels` | Stored ML model metadata |
| `LinkFailurePredictions` | Failure risk per update |
| `MeterConnectivityConfig` | Thresholds + ML settings |
| `LinkTypes` | CELLULAR / SATELLITE |
| `LinkSwitchEvents` | Connectivity fallback events |

---

## 📊 Analytics Views

| View Name | Purpose |
|----------|---------|
| `vw_FirmwareVersionKPI` | Firmware KPIs (avg time, failure rate) |
| `vw_ProblemMeters` | Meters with high failures or slow updates |
| `vw_FailureRootCause` | Network context around update failures |
| `vw_MLPredictionPerformance` | Prediction accuracy vs actual |

---

## 🧠 What This System Helps You Achieve

### Identify:
- Slow-performing meters  
- Failing firmware versions  
- Sites with persistent weak network  
- Timeouts caused by poor RSSI  
- When satellite fallback is necessary  

### Predict:
- Probability a firmware update will fail  
- Whether Cellular or Satellite should be used  
- Which meters are likely to cause operational delays  

---

## 🔮 Future Work

### 🌐 IoT Device Integration
- MQTT pipeline for real-time ingestion  
- Device-heartbeat monitoring  
- Over-the-air config commands  

### 🤖 ML Improvements
- Add RandomForest/GBM/Neural models  
- Rolling model retraining automation  
- Per-site adaptive RSSI thresholds  

### 📡 Advanced Connectivity Logic
- Multi-link support (Wi-Fi / LoRaWAN / Satellite)  
- Predictive switching based on moving RSSI trends  
- Cost-optimized routing (cellular vs satellite billing)  

### 📈 Dashboard Enhancements
- Real-time streaming dashboards  
- Predictive analytics panel  
- Site-level aggregation (failures by county/district)

---

## 📜 License

MIT License 
---

## 👤 Author

**Brian Rono**  
Smart Meter Systems Engineer & Machine Learning Researcher  

---

## ⭐ Support

If this project is helpful, consider giving the repo a ⭐ on GitHub.  


