#include "datamanager.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSaveFile>
#include <QTime>
#include <QDebug>

DataManager::DataManager(QObject *parent)
    : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, &DataManager::onFileChanged);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &DataManager::onDirectoryChanged);

    m_reloadTimer.setSingleShot(true);
    m_reloadTimer.setInterval(100);
    connect(&m_reloadTimer, &QTimer::timeout, this, &DataManager::processPendingReloads);
}

DataManager::~DataManager() = default;

QStringList DataManager::trackedFilenames() const
{
    return {
        QStringLiteral("traffic_violations.json"),
        QStringLiteral("priority_vehicles.json"),
        QStringLiteral("signal_control.json"),
        QStringLiteral("system_health.json"),
        QStringLiteral("monitor_ui.json"),
        QStringLiteral("robot_telemetry.json"),
    };
}

QString DataManager::filePathFor(const QString &filename) const
{
    return QDir(m_databasePath).filePath(filename);
}

QVariant DataManager::defaultDataFor(const QString &filename) const
{
    if (filename == "traffic_violations.json") {
        return QVariantList{
            QVariantMap{
                {"color", "#e74c3c"},
                {"plate", "جــ م ٥٠٠"},
                {"violation", "تجاوز السرعة الخطيرة"},
                {"time", "20:22"},
                {"timestamp", 1713893040},
            },
            QVariantMap{
                {"color", "#c0392b"},
                {"plate", "ب د ٢٠٠"},
                {"violation", "تجاوز الإشارة"},
                {"time", "20:23"},
                {"timestamp", 1713893100},
            },
        };
    }

    if (filename == "priority_vehicles.json") {
        return QVariantList{
            QVariantMap{
                {"type", "Ambulance"},
                {"distance", "150m"},
                {"level", "1"},
                {"status", "Approaching"},
                {"color", "#d68a57"},
                {"checked", true},
            },
            QVariantMap{
                {"type", "Fire Truck"},
                {"distance", "210m"},
                {"level", "2"},
                {"status", "Path Cleared"},
                {"color", "#4fbf67"},
                {"checked", false},
            },
        };
    }

    if (filename == "signal_control.json") {
        return QVariantMap{
            {"activeDir", "A"},
            {"aiMode", true},
            {"manualMode", false},
            {"yellowDuration", 3},
            {"streetADuration", 30},
            {"streetBDuration", 25},
            {"lastUpdated", QDateTime::currentSecsSinceEpoch()},
        };
    }

    if (filename == "monitor_ui.json") {
        return QVariantMap{
            {"hud", QVariantMap{
                {"healthTitle", "SYSTEM HEALTH"},
                {"healthSubtitle", "Realtime diagnostics"},
                {"networkLabel", "NETWORK"},
                {"batteryLabel", "BATTERY"},
                {"dateLabel", "DATE"},
                {"timeLabel", "TIME"},
            }},
            {"cameraNetwork", QVariantMap{
                {"title", "ROS CAMERA NETWORK + STREET AI"},
                {"subtitle", "Topics: live ROS camera feeds and AI street monitor"},
                {"liveSuffix", "LIVE"},
            }},
            {"cameraCards", QVariantMap{
                {"robot", QVariantMap{
                    {"title", "Robot FPV"},
                    {"onlineText", "ROS image stream online"},
                    {"offlineText", "Waiting for /cam_robot"},
                }},
                {"streetA", QVariantMap{
                    {"title", "Street A"},
                    {"onlineText", "AI visibility normal"},
                    {"offlineText", "Waiting for /cam_A"},
                }},
                {"streetB", QVariantMap{
                    {"title", "Street B"},
                    {"onlineText", "AI tracking active"},
                    {"offlineText", "Waiting for /cma_B"},
                }},
            }},
            {"map", QVariantMap{
                {"title", "LIVE STREET MAP"},
                {"subtitle", "Intersection overview and route intelligence"},
                {"eventSuffix", "EVENTS"},
                {"telemetryTitle", "ROBOT TELEMETRY"},
                {"zoomLevel", 16},
            }},
            {"aiPanel", QVariantMap{
                {"title", "AI STREET MONITOR"},
                {"summaryLabel", "SUMMARY"},
                {"fallbackSummary", "Waiting for AI summary on /street_ai_monitor"},
                {"queueTitle", "AI INCIDENT QUEUE"},
                {"queueSuffix", "traffic events synced from live datastore"},
                {"robotLabel", "ROBOT"},
                {"streetALabel", "STREET A"},
                {"streetBLabel", "STREET B"},
                {"emptyQueueTitle", "No incidents"},
                {"emptyQueueSubtitle", "Traffic events will appear here as soon as the database updates."},
            }},
            {"trafficPanel", QVariantMap{
                {"title", "TRAFFIC MANAGEMENT INTERFACE"},
                {"violationsTitle", "TRAFFIC VIOLATION LOG"},
                {"vehiclesTitle", "PRIORITY VEHICLE QUEUE"},
                {"controlTitle", "INTELLIGENT INTERSECTION CONTROL"},
                {"signalModesTitle", "SIGNAL TIMING & MODES"},
                {"signalPersistenceNote", "Signal state is saved to signal_control.json immediately, and external edits reload here automatically."},
                {"colorHeader", "COLOR"},
                {"plateHeader", "LICENSE PLATE"},
                {"violationHeader", "VIOLATION"},
                {"timeHeader", "TIME"},
                {"setHeader", "SET"},
                {"vehicleHeader", "VEHICLE"},
                {"distanceHeader", "DISTANCE"},
                {"levelHeader", "LVL"},
                {"statusHeader", "STATUS"},
                {"addDemoLabel", "ADD DEMO"},
                {"clearLatestLabel", "CLEAR LATEST"},
                {"yellowDurationLabel", "YELLOW LIGHT DURATION"},
                {"goStreetALabel", "GO STREET A"},
                {"goStreetBLabel", "GO STREET B"},
                {"allStopLabel", "ALL STOP (RED)"},
                {"streetALabel", "STREET A"},
                {"streetBLabel", "STREET B"},
                {"aiAutoLabel", "AI AUTO"},
                {"manualLabel", "MANUAL"},
                {"demoViolations", QVariantList{
                    QVariantMap{{"color", "#e74c3c"}, {"message", "تجاوز السرعة"}},
                    QVariantMap{{"color", "#d35400"}, {"message", "تجاوز الإشارة"}},
                    QVariantMap{{"color", "#f1c40f"}, {"message", "سير عكسي"}},
                    QVariantMap{{"color", "#9b59b6"}, {"message", "وقوف مخالف"}},
                }},
            }},
            {"bottomBar", QVariantMap{
                {"homeLabel", "HOME"},
                {"emergencyLabel", "EMERGENCY"},
                {"systemLabel", "SYSTEM"},
            }},
            {"bottomStatus", QVariantMap{
                {"networkTitle", "ROS NETWORK"},
                {"streamSuffix", "STREAMS ONLINE"},
                {"aiTopicLabel", "AI TOPIC"},
            }},
        };
    }

    if (filename == "robot_telemetry.json") {
        return QVariantMap{
            {"label", "ROBOT TELEMETRY"},
            {"status", "Monitoring"},
            {"lat", 30.60291},
            {"lon", 32.30487},
            {"zoom", 16},
            {"missionTime", "00:00:00"},
            {"routeState", "Intersection standby"},
            {"lastUpdated", QDateTime::currentSecsSinceEpoch()},
        };
    }

    return QVariantMap{
        {"systemHealth", 85},
        {"network", "5G"},
        {"battery", 90},
        {"cpuUsage", 35},
        {"memoryUsage", 55},
        {"temperature", 42},
        {"lastUpdated", QDateTime::currentSecsSinceEpoch()},
    };
}

bool DataManager::ensureDatabaseReady()
{
    if (m_databasePath.isEmpty()) {
        emit errorOccurred("Database path is empty.");
        return false;
    }

    QDir dbDir(m_databasePath);
    if (!dbDir.exists() && !QDir().mkpath(m_databasePath)) {
        emit errorOccurred("Failed to create database directory: " + m_databasePath);
        return false;
    }

    for (const QString &filename : trackedFilenames()) {
        if (!ensureJsonFileExists(filename)) {
            return false;
        }
    }

    return true;
}

bool DataManager::ensureJsonFileExists(const QString &filename)
{
    const QString filePath = filePathFor(filename);
    if (QFileInfo::exists(filePath)) {
        return true;
    }

    return saveJsonFile(filename, defaultDataFor(filename));
}

void DataManager::syncWatchPaths()
{
    const QStringList expectedFiles = [&]() {
        QStringList files;
        files.reserve(trackedFilenames().size());
        for (const QString &filename : trackedFilenames()) {
            files.append(filePathFor(filename));
        }
        return files;
    }();

    for (const QString &watchedFile : m_watcher.files()) {
        if (!expectedFiles.contains(watchedFile)) {
            m_watcher.removePath(watchedFile);
        }
    }

    for (const QString &path : expectedFiles) {
        if (QFileInfo::exists(path) && !m_watcher.files().contains(path)) {
            m_watcher.addPath(path);
        }
    }

    if (!m_databasePath.isEmpty() && QFileInfo::exists(m_databasePath) && !m_watcher.directories().contains(m_databasePath)) {
        m_watcher.addPath(m_databasePath);
    }
}

void DataManager::setDatabasePath(const QString &path)
{
    if (m_databasePath == path) {
        return;
    }

    for (const QString &file : m_watcher.files()) {
        m_watcher.removePath(file);
    }
    for (const QString &directory : m_watcher.directories()) {
        m_watcher.removePath(directory);
    }

    m_databasePath = path;
    emit databasePathChanged();
    loadAllData();
}

void DataManager::loadAllData()
{
    if (!ensureDatabaseReady()) {
        return;
    }

    reloadAllFiles();
    syncWatchPaths();
    emit dataLoaded();
}

void DataManager::reloadAllFiles()
{
    for (const QString &filename : trackedFilenames()) {
        reloadFile(filename);
    }
}

bool DataManager::reloadFile(const QString &filename)
{
    QVariant data;
    if (!loadJsonFile(filename, data)) {
        return false;
    }

    if (filename == "traffic_violations.json") {
        m_trafficViolations = data.toList();
        emit trafficViolationsChanged();
        return true;
    }

    if (filename == "priority_vehicles.json") {
        m_priorityVehicles = data.toList();
        emit priorityVehiclesChanged();
        return true;
    }

    if (filename == "signal_control.json") {
        m_signalControl = data.toMap();
        emit signalControlChanged();
        return true;
    }

    if (filename == "system_health.json") {
        m_systemHealth = data.toMap();
        emit systemHealthChanged();
        return true;
    }

    if (filename == "monitor_ui.json") {
        m_monitorUi = data.toMap();
        emit monitorUiChanged();
        return true;
    }

    if (filename == "robot_telemetry.json") {
        m_robotTelemetry = data.toMap();
        emit robotTelemetryChanged();
        return true;
    }

    return false;
}

void DataManager::scheduleReload(const QString &path)
{
    if (path.isEmpty()) {
        for (const QString &filename : trackedFilenames()) {
            m_pendingReloadFiles.insert(filename);
        }
    } else {
        m_pendingReloadFiles.insert(QFileInfo(path).fileName());
    }

    m_reloadTimer.start();
}

void DataManager::processPendingReloads()
{
    if (!ensureDatabaseReady()) {
        return;
    }

    syncWatchPaths();

    const auto pendingFiles = m_pendingReloadFiles.values();
    m_pendingReloadFiles.clear();

    for (const QString &filename : pendingFiles) {
        if (trackedFilenames().contains(filename)) {
            reloadFile(filename);
        }
    }
}

bool DataManager::loadJsonFile(const QString &filename, QVariant &data)
{
    const QString filePath = filePathFor(filename);
    QFile file(filePath);

    if (!file.exists()) {
        emit errorOccurred("File not found: " + filePath);
        return false;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred("Cannot open file: " + filePath);
        return false;
    }

    const QByteArray jsonData = file.readAll();
    file.close();

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError || doc.isNull()) {
        emit errorOccurred("Invalid JSON in file: " + filePath + " (" + parseError.errorString() + ")");
        return false;
    }

    if (doc.isArray()) {
        data = doc.array().toVariantList();
        return true;
    }

    if (doc.isObject()) {
        data = doc.object().toVariantMap();
        return true;
    }

    emit errorOccurred("Unsupported JSON root in file: " + filePath);
    return false;
}

bool DataManager::saveJsonFile(const QString &filename, const QVariant &data)
{
    if (m_databasePath.isEmpty()) {
        emit errorOccurred("Cannot save JSON without a database path.");
        return false;
    }

    if (!QDir().mkpath(m_databasePath)) {
        emit errorOccurred("Cannot create database directory: " + m_databasePath);
        return false;
    }

    const QString filePath = filePathFor(filename);
    QJsonDocument doc;

    if (data.metaType().id() == QMetaType::QVariantList) {
        doc = QJsonDocument(QJsonArray::fromVariantList(data.toList()));
    } else if (data.metaType().id() == QMetaType::QVariantMap) {
        doc = QJsonDocument(QJsonObject::fromVariantMap(data.toMap()));
    } else {
        emit errorOccurred("Unsupported data type for JSON save: " + filename);
        return false;
    }

    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred("Cannot write to file: " + filePath);
        return false;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    if (!file.commit()) {
        emit errorOccurred("Failed to commit JSON file: " + filePath);
        return false;
    }

    syncWatchPaths();
    return true;
}

void DataManager::updateTrafficViolations(const QVariantList &violations)
{
    m_trafficViolations = violations;
    saveJsonFile("traffic_violations.json", violations);
    emit trafficViolationsChanged();
}

void DataManager::updatePriorityVehicles(const QVariantList &vehicles)
{
    m_priorityVehicles = vehicles;
    saveJsonFile("priority_vehicles.json", vehicles);
    emit priorityVehiclesChanged();
}

void DataManager::updateSignalControl(const QVariantMap &control)
{
    QVariantMap nextControl = control;
    if (!nextControl.contains("lastUpdated")) {
        nextControl["lastUpdated"] = QDateTime::currentSecsSinceEpoch();
    }

    m_signalControl = nextControl;
    saveJsonFile("signal_control.json", nextControl);
    emit signalControlChanged();
}

void DataManager::updateSystemHealth(const QVariantMap &health)
{
    QVariantMap nextHealth = health;
    if (!nextHealth.contains("lastUpdated")) {
        nextHealth["lastUpdated"] = QDateTime::currentSecsSinceEpoch();
    }

    m_systemHealth = nextHealth;
    saveJsonFile("system_health.json", nextHealth);
    emit systemHealthChanged();
}

void DataManager::updateMonitorUi(const QVariantMap &ui)
{
    m_monitorUi = ui;
    saveJsonFile("monitor_ui.json", ui);
    emit monitorUiChanged();
}

void DataManager::updateRobotTelemetry(const QVariantMap &telemetry)
{
    QVariantMap nextTelemetry = telemetry;
    if (!nextTelemetry.contains("lastUpdated")) {
        nextTelemetry["lastUpdated"] = QDateTime::currentSecsSinceEpoch();
    }

    m_robotTelemetry = nextTelemetry;
    saveJsonFile("robot_telemetry.json", nextTelemetry);
    emit robotTelemetryChanged();
}

void DataManager::patchSignalControl(const QVariantMap &patch)
{
    QVariantMap merged = m_signalControl;
    for (auto it = patch.begin(); it != patch.end(); ++it) {
        merged[it.key()] = it.value();
    }
    updateSignalControl(merged);
}

void DataManager::patchSystemHealth(const QVariantMap &patch)
{
    QVariantMap merged = m_systemHealth;
    for (auto it = patch.begin(); it != patch.end(); ++it) {
        merged[it.key()] = it.value();
    }
    updateSystemHealth(merged);
}

void DataManager::patchMonitorUi(const QVariantMap &patch)
{
    QVariantMap merged = m_monitorUi;
    for (auto it = patch.begin(); it != patch.end(); ++it) {
        merged[it.key()] = it.value();
    }
    updateMonitorUi(merged);
}

void DataManager::patchRobotTelemetry(const QVariantMap &patch)
{
    QVariantMap merged = m_robotTelemetry;
    for (auto it = patch.begin(); it != patch.end(); ++it) {
        merged[it.key()] = it.value();
    }
    updateRobotTelemetry(merged);
}

void DataManager::addTrafficViolation(const QVariantMap &violation)
{
    QVariantMap nextViolation = violation;
    if (!nextViolation.contains("time")) {
        nextViolation["time"] = QTime::currentTime().toString("hh:mm");
    }
    if (!nextViolation.contains("timestamp")) {
        nextViolation["timestamp"] = QDateTime::currentSecsSinceEpoch();
    }

    m_trafficViolations.prepend(nextViolation);
    saveJsonFile("traffic_violations.json", m_trafficViolations);
    emit trafficViolationsChanged();
}

void DataManager::removeTrafficViolation(int index)
{
    if (index < 0 || index >= m_trafficViolations.size()) {
        return;
    }

    m_trafficViolations.removeAt(index);
    saveJsonFile("traffic_violations.json", m_trafficViolations);
    emit trafficViolationsChanged();
}

void DataManager::onFileChanged(const QString &path)
{
    scheduleReload(path);
}

void DataManager::onDirectoryChanged(const QString &path)
{
    Q_UNUSED(path);
    scheduleReload();
}
