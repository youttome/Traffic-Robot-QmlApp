# Traffic Robot Monitoring UI

Qt 6 + QML monitoring dashboard for a traffic robot / smart intersection system.

The project combines:
- a live QML operator interface
- JSON-backed local datastore with file watching
- optional ROS 2 camera + AI topic subscriptions
- OpenCV image decoding for ROS image streams

## Main Features

- Live monitor screen for robot, street A, and street B camera feeds
- Street AI panel for `/street_ai_monitor` summaries
- File-based database with automatic reload when JSON files change
- Traffic control panel with violations, priority vehicles, and signal control
- Map card with robot telemetry overlay
- Runtime support for ROS 2 when `rclcpp`, `sensor_msgs`, and `std_msgs` are available
- Fallback behavior when ROS publishers are offline

## Project Layout

```text
.
├── CMakeLists.txt
├── main.cpp
├── datamanager.cpp / datamanager.h
├── rosstreammanager.cpp / rosstreammanager.h
├── camera.cpp / camera.h
├── systemmonitor.cpp / systemmonitor.h
├── include/
├── src/
├── qml/
│   ├── Main.qml
│   ├── Main_window.qml
│   ├── Left_Bar.qml
│   ├── Bottom_Bar.qml
│   ├── MapView.qml
│   └── monitor/
│       ├── Monitor_window.qml
│       ├── CameraNetwork.qml
│       ├── CameraCard.qml
│       ├── MapIntelCard.qml
│       ├── StreetAIPanel.qml
│       ├── TrafficPanel.qml
│       ├── HUDStatusBar.qml
│       ├── BottomBar.qml
│       └── BottomBarRight.qml
├── QUICKSTART.md
├── DATABASE_SETUP.md
├── PROJECT_TASKS.md
└── GITHUB_PUSH.md
```

## Requirements

- CMake `>= 3.16`
- C++17 compiler
- Qt `>= 6.5`
- OpenCV
- Optional: ROS 2 with `rclcpp`, `sensor_msgs`, `std_msgs`

## Build

If `qt-cmake` is already in your `PATH`:

```bash
qt-cmake -S . -B build-qt6
cmake --build build-qt6 -j4
```

Local Qt example used on this machine:

```bash
/home/abso/data/6.10.1/gcc_64/bin/qt-cmake -S . -B build-qt6
cmake --build build-qt6 -j4
```

## Run

Default run:

```bash
./build-qt6/appCircleBarsUI
```

Run with a custom database folder:

```bash
MONITOR_APP_DB_PATH=/path/to/monitor_app ./build-qt6/appCircleBarsUI
```

## Database

The app uses a JSON datastore. By default it reads and writes:

```text
/media/abso/project/database/monitor_app
```

Current live files:

- `traffic_violations.json`
- `priority_vehicles.json`
- `signal_control.json`
- `system_health.json`
- `monitor_ui.json`
- `robot_telemetry.json`

Changes made:
- in the app are saved back to JSON
- in the JSON files are reloaded into the app automatically

See [DATABASE_SETUP.md](DATABASE_SETUP.md) for the full schema.

## ROS 2 Integration

When ROS 2 dependencies are available at configure time, the app subscribes to:

- `/cam_robot`
- `/cam_A`
- `/cma_B`
- `/street_ai_monitor`
- compressed camera companions such as `/cam_robot/compressed`

Topic names can be overridden with environment variables:

- `MONITOR_CAM_ROBOT_TOPIC`
- `MONITOR_CAM_A_TOPIC`
- `MONITOR_CAM_B_TOPIC`
- `MONITOR_STREET_AI_TOPIC`

If no publishers are active, the UI stays online with placeholder frames and waiting states.

## How To Use The Source Code

1. Build the app with Qt 6 and OpenCV.
2. Launch it once so the JSON database files are generated.
3. Edit the JSON files to change labels, signal state, telemetry, or traffic events.
4. If you use ROS 2, start your publishers for camera and AI topics.
5. Customize QML in `qml/` and backend logic in `datamanager.*` or `rosstreammanager.*`.

Good starting points:

- [qml/Main.qml](qml/Main.qml)
- [qml/monitor/Monitor_window.qml](qml/monitor/Monitor_window.qml)
- [datamanager.cpp](datamanager.cpp)
- [rosstreammanager.cpp](rosstreammanager.cpp)

## Documentation

- [QUICKSTART.md](QUICKSTART.md): fastest path from clone to running app
- [DATABASE_SETUP.md](DATABASE_SETUP.md): JSON database structure and sync behavior
- [PROJECT_TASKS.md](PROJECT_TASKS.md): ordered task list from first step to final validation
- [GITHUB_PUSH.md](GITHUB_PUSH.md): how to prepare and push this repo to GitHub

## GitHub Publishing

Before pushing publicly:

- review `.gitignore`
- remove local build output if not needed
- choose and add a project `LICENSE` file
- check whether you want sample/demo assets in the public repository

The push steps are documented in [GITHUB_PUSH.md](GITHUB_PUSH.md).

## Notes

- The map currently uses the Qt OSM plugin. If the tiles provider or API key is restricted, the app may still run but the map may show provider warnings.
- The default Street B ROS topic is `/cma_B` because that is what the current code is configured to use.

## Asset And Origin Credits

This repository started from a Qt sample and has been adapted into a traffic robot monitoring project.

Original sample credits from the inherited project:

- Source origin: The Qt Company example project
- Background image: https://stocksnap.io/photo/futuristic-technology-YWJQBD3VIX
- Background image license: https://creativecommons.org/publicdomain/zero/1.0/
- Heart image: https://opengameart.org/content/2d-heart-2-animations
- Heart image license: https://creativecommons.org/licenses/by/4.0/
- Font: https://www.1001fonts.com/monofonto-font.html
- Font license: https://st.1001fonts.net/license/monofonto/Typodermic%20Desktop%20EULA%202023.pdf

## License

There is currently no standalone repository `LICENSE` file in this project tree.

Before publishing to GitHub, add the license you want this version of the project to use and verify that all bundled assets are compatible with it.
