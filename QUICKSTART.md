# Quick Start

This guide gets the app running as fast as possible.

## 1. Install Requirements

You need:

- Qt 6.5 or newer
- CMake 3.16 or newer
- OpenCV
- Optional: ROS 2 if you want live ROS topics

## 2. Build The App

```bash
qt-cmake -S . -B build-qt6
cmake --build build-qt6 -j4
```

If `qt-cmake` is not in `PATH`, use your local Qt installation path instead.

## 3. Start The App

```bash
./build-qt6/appCircleBarsUI
```

Optional custom database path:

```bash
MONITOR_APP_DB_PATH=/path/to/monitor_app ./build-qt6/appCircleBarsUI
```

## 4. Confirm The Database Was Created

After the first launch, you should have:

```text
monitor_app/
├── traffic_violations.json
├── priority_vehicles.json
├── signal_control.json
├── system_health.json
├── monitor_ui.json
└── robot_telemetry.json
```

## 5. Test Live JSON Sync

Edit one file while the app is running.

Example:

```json
{
  "label": "ROBOT TELEMETRY",
  "lat": 30.60291,
  "lon": 32.30487,
  "zoom": 16,
  "missionTime": "00:12:10",
  "routeState": "Robot dispatched",
  "status": "Monitoring"
}
```

Save it to `robot_telemetry.json` and the map panel should update automatically.

## 6. Run With ROS 2

If ROS 2 is installed and found during CMake configure, the app can subscribe to:

- `/cam_robot`
- `/cam_A`
- `/cma_B`
- `/street_ai_monitor`

You can override those topic names before launching:

```bash
export MONITOR_CAM_ROBOT_TOPIC=/cam_robot
export MONITOR_CAM_A_TOPIC=/cam_A
export MONITOR_CAM_B_TOPIC=/cma_B
export MONITOR_STREET_AI_TOPIC=/street_ai_monitor
./build-qt6/appCircleBarsUI
```

## 7. Where To Edit

- QML screens: `qml/`
- Monitor page: `qml/monitor/`
- JSON data backend: `datamanager.cpp`, `datamanager.h`
- ROS stream backend: `rosstreammanager.cpp`, `rosstreammanager.h`

## 8. Next Docs

- Full database details: [DATABASE_SETUP.md](DATABASE_SETUP.md)
- Full project workflow: [PROJECT_TASKS.md](PROJECT_TASKS.md)
- GitHub push guide: [GITHUB_PUSH.md](GITHUB_PUSH.md)
