# Database Setup

The application uses a file-based JSON datastore and keeps it synchronized with QML in real time.

## Database Path

Default path:

```text
/media/abso/project/database/monitor_app
```

Override it with:

```bash
MONITOR_APP_DB_PATH=/your/path/monitor_app ./build-qt6/appCircleBarsUI
```

## Live Behavior

- If a JSON file does not exist, the app creates it with default data.
- If the app changes data, it writes the JSON file immediately.
- If an external tool edits a JSON file, the app reloads it automatically.
- Writes use `QSaveFile`, so saves are atomic.

## Database Files

## 1. `traffic_violations.json`

Root type: JSON array

Example item:

```json
{
  "color": "#e74c3c",
  "plate": "AI-2367",
  "violation": "تجاوز السرعة",
  "time": "02:07",
  "timestamp": 1776983500
}
```

Fields:

- `color`: UI color for the event
- `plate`: license plate or event tag
- `violation`: violation text
- `time`: human-readable time
- `timestamp`: Unix timestamp

## 2. `priority_vehicles.json`

Root type: JSON array

Example item:

```json
{
  "type": "Ambulance",
  "distance": "150m",
  "level": "1",
  "status": "Approaching",
  "color": "#d68a57",
  "checked": true
}
```

Fields:

- `type`: vehicle name
- `distance`: distance label
- `level`: priority level
- `status`: status label shown in UI
- `color`: status color
- `checked`: checkbox state

## 3. `signal_control.json`

Root type: JSON object

Example:

```json
{
  "activeDir": "NONE",
  "aiMode": false,
  "manualMode": true,
  "yellowDuration": 10,
  "streetADuration": 18,
  "streetBDuration": 32,
  "lastUpdated": 1776983500
}
```

Fields:

- `activeDir`: `A`, `B`, `NONE`, `YELLOW_A`, or `YELLOW_B`
- `aiMode`: AI traffic mode enabled
- `manualMode`: manual operator mode enabled
- `yellowDuration`: yellow light duration in seconds
- `streetADuration`: saved street A duration
- `streetBDuration`: saved street B duration
- `lastUpdated`: Unix timestamp

## 4. `system_health.json`

Root type: JSON object

Example:

```json
{
  "systemHealth": 85,
  "network": "5G",
  "battery": 100,
  "cpuUsage": 17,
  "memoryUsage": 55,
  "temperature": 42,
  "lastUpdated": 1776987038
}
```

Fields:

- `systemHealth`: overall health score
- `network`: network label
- `battery`: battery percent
- `cpuUsage`: CPU percent
- `memoryUsage`: memory percent
- `temperature`: temperature in Celsius
- `lastUpdated`: Unix timestamp

## 5. `monitor_ui.json`

Root type: JSON object

Purpose:

- stores monitor labels
- stores panel text
- stores camera card wording
- stores map card labels
- stores bottom bar labels
- stores demo traffic event templates

Top-level sections:

- `hud`
- `cameraNetwork`
- `cameraCards`
- `map`
- `aiPanel`
- `trafficPanel`
- `bottomBar`
- `bottomStatus`

Example:

```json
{
  "cameraNetwork": {
    "title": "ROS CAMERA NETWORK + STREET AI",
    "subtitle": "Topics: live ROS camera feeds and AI street monitor",
    "liveSuffix": "LIVE"
  },
  "map": {
    "title": "LIVE STREET MAP",
    "subtitle": "Intersection overview and route intelligence",
    "eventSuffix": "EVENTS",
    "telemetryTitle": "ROBOT TELEMETRY",
    "zoomLevel": 16
  }
}
```

## 6. `robot_telemetry.json`

Root type: JSON object

Purpose:

- feeds the monitor map card
- stores robot position and mission overlay data

Example:

```json
{
  "label": "ROBOT TELEMETRY",
  "status": "Monitoring",
  "lat": 30.60291,
  "lon": 32.30487,
  "zoom": 16,
  "missionTime": "00:00:00",
  "routeState": "Intersection standby",
  "lastUpdated": 1776987441
}
```

Fields:

- `label`: telemetry label
- `status`: free text status
- `lat`: latitude
- `lon`: longitude
- `zoom`: map zoom level
- `missionTime`: mission timer text
- `routeState`: route / mission state text
- `lastUpdated`: Unix timestamp

## Code Paths

Main files involved:

- `main.cpp`: injects `dataManager` into QML and sets database path
- `datamanager.h`
- `datamanager.cpp`

Main QML consumers:

- `qml/monitor/TrafficPanel.qml`
- `qml/monitor/HUDStatusBar.qml`
- `qml/monitor/CameraNetwork.qml`
- `qml/monitor/MapIntelCard.qml`
- `qml/monitor/StreetAIPanel.qml`
- `qml/monitor/BottomBar.qml`
- `qml/monitor/BottomBarRight.qml`

## Extending The Database

To add a new JSON-backed feature:

1. Add the filename to `trackedFilenames()` in `datamanager.cpp`.
2. Add default content in `defaultDataFor()`.
3. Add a `Q_PROPERTY` in `datamanager.h`.
4. Load and emit changes in `reloadFile()`.
5. Add update or patch methods.
6. Bind the new property in QML.

## Troubleshooting

- Invalid JSON: the app logs an error and keeps the last valid in-memory data.
- File not created: check write permissions for the database directory.
- UI not updating: confirm you edited a tracked JSON file and saved valid JSON.
- ROS data missing: JSON sync may still work even when ROS publishers are offline.
