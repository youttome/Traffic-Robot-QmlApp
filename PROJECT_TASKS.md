# Project Tasks

Use this as the ordered workflow from the first setup step to the final release step.

## Phase 1. Prepare The Environment

- [ ] Install Qt 6
- [ ] Install CMake 3.16 or newer
- [ ] Install OpenCV
- [ ] Install ROS 2 only if live ROS topics are required
- [ ] Confirm `qt-cmake` works in terminal

## Phase 2. Get The Source Code Ready

- [ ] Clone or copy the project into your workspace
- [ ] Review `.gitignore`
- [ ] Read [README.md](README.md)
- [ ] Read [QUICKSTART.md](QUICKSTART.md)

## Phase 3. Configure Runtime Data

- [ ] Choose the database folder
- [ ] Set `MONITOR_APP_DB_PATH` if you do not want the default path
- [ ] Launch the app once to auto-create JSON files
- [ ] Confirm all six JSON files exist

## Phase 4. Build The Project

- [ ] Configure CMake with Qt
- [ ] Build `appCircleBarsUI`
- [ ] Fix any missing dependency errors before continuing

Suggested commands:

```bash
qt-cmake -S . -B build-qt6
cmake --build build-qt6 -j4
```

## Phase 5. Run And Validate The Base UI

- [ ] Start `./build-qt6/appCircleBarsUI`
- [ ] Confirm `Main.qml` loads correctly
- [ ] Confirm the monitor page opens
- [ ] Confirm there are no blocking QML runtime errors

## Phase 6. Validate Database Sync

- [ ] Edit `system_health.json` while the app is running
- [ ] Confirm the HUD updates
- [ ] Edit `signal_control.json`
- [ ] Confirm the traffic control panel updates
- [ ] Edit `monitor_ui.json`
- [ ] Confirm titles or labels update live
- [ ] Edit `robot_telemetry.json`
- [ ] Confirm map position or mission text updates

## Phase 7. Validate ROS Integration

- [ ] Build in an environment where ROS 2 packages are found
- [ ] Start publishers for `/cam_robot`, `/cam_A`, `/cma_B`
- [ ] Start publisher for `/street_ai_monitor`
- [ ] Confirm camera cards switch from `WAITING` to `LIVE`
- [ ] Confirm AI summary updates in the side panel

## Phase 8. Customize The Product

- [ ] Update labels and monitor wording in `monitor_ui.json`
- [ ] Update default telemetry values in `robot_telemetry.json`
- [ ] Improve QML design inside `qml/monitor/`
- [ ] Adjust backend logic in `datamanager.*` or `rosstreammanager.*` if needed

## Phase 9. Clean The Repository

- [ ] Remove temporary local files that should not be committed
- [ ] Make sure build folders are ignored by `.gitignore`
- [ ] Review `git status`
- [ ] Keep only source, assets, and documentation that belong in GitHub

## Phase 10. Prepare For GitHub

- [ ] Review [GITHUB_PUSH.md](GITHUB_PUSH.md)
- [ ] Update `README.md` if project details changed
- [ ] Add a `LICENSE` file
- [ ] Decide whether database examples should be included
- [ ] Write a clear first commit message

## Phase 11. Push The Repository

- [ ] Initialize Git if needed
- [ ] Add the GitHub remote
- [ ] Commit source code and docs
- [ ] Push the main branch
- [ ] Verify repository files on GitHub

## Phase 12. Final Validation

- [ ] Clone the repo into a fresh folder
- [ ] Build it again from scratch
- [ ] Run it with the README instructions only
- [ ] Fix any missing step in the docs

When all boxes are done, the project is ready for handoff or public sharing.
