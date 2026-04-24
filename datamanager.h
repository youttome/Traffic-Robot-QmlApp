#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QFileSystemWatcher>
#include <QSet>
#include <QTimer>

class DataManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList trafficViolations READ trafficViolations NOTIFY trafficViolationsChanged)
    Q_PROPERTY(QVariantList priorityVehicles READ priorityVehicles NOTIFY priorityVehiclesChanged)
    Q_PROPERTY(QVariantMap signalControl READ signalControl NOTIFY signalControlChanged)
    Q_PROPERTY(QVariantMap systemHealth READ systemHealth NOTIFY systemHealthChanged)
    Q_PROPERTY(QVariantMap monitorUi READ monitorUi NOTIFY monitorUiChanged)
    Q_PROPERTY(QVariantMap robotTelemetry READ robotTelemetry NOTIFY robotTelemetryChanged)
    Q_PROPERTY(QString databasePath READ databasePath WRITE setDatabasePath NOTIFY databasePathChanged)

public:
    explicit DataManager(QObject *parent = nullptr);
    ~DataManager();

    // Getters
    QVariantList trafficViolations() const { return m_trafficViolations; }
    QVariantList priorityVehicles() const { return m_priorityVehicles; }
    QVariantMap signalControl() const { return m_signalControl; }
    QVariantMap systemHealth() const { return m_systemHealth; }
    QVariantMap monitorUi() const { return m_monitorUi; }
    QVariantMap robotTelemetry() const { return m_robotTelemetry; }
    QString databasePath() const { return m_databasePath; }

    // Setters & Methods
    void setDatabasePath(const QString &path);

    Q_INVOKABLE void loadAllData();
    Q_INVOKABLE void updateTrafficViolations(const QVariantList &violations);
    Q_INVOKABLE void updatePriorityVehicles(const QVariantList &vehicles);
    Q_INVOKABLE void updateSignalControl(const QVariantMap &control);
    Q_INVOKABLE void updateSystemHealth(const QVariantMap &health);
    Q_INVOKABLE void updateMonitorUi(const QVariantMap &ui);
    Q_INVOKABLE void updateRobotTelemetry(const QVariantMap &telemetry);
    Q_INVOKABLE void patchSignalControl(const QVariantMap &patch);
    Q_INVOKABLE void patchSystemHealth(const QVariantMap &patch);
    Q_INVOKABLE void patchMonitorUi(const QVariantMap &patch);
    Q_INVOKABLE void patchRobotTelemetry(const QVariantMap &patch);

    Q_INVOKABLE void addTrafficViolation(const QVariantMap &violation);
    Q_INVOKABLE void removeTrafficViolation(int index);

signals:
    void trafficViolationsChanged();
    void priorityVehiclesChanged();
    void signalControlChanged();
    void systemHealthChanged();
    void monitorUiChanged();
    void robotTelemetryChanged();
    void databasePathChanged();
    void dataLoaded();
    void errorOccurred(const QString &error);

private slots:
    void onFileChanged(const QString &path);
    void onDirectoryChanged(const QString &path);
    void processPendingReloads();

private:
    QStringList trackedFilenames() const;
    QString filePathFor(const QString &filename) const;
    QVariant defaultDataFor(const QString &filename) const;
    bool ensureDatabaseReady();
    bool ensureJsonFileExists(const QString &filename);
    void syncWatchPaths();
    void scheduleReload(const QString &path = QString());
    void reloadAllFiles();
    bool reloadFile(const QString &filename);
    bool loadJsonFile(const QString &filename, QVariant &data);
    bool saveJsonFile(const QString &filename, const QVariant &data);

    QString m_databasePath;
    QVariantList m_trafficViolations;
    QVariantList m_priorityVehicles;
    QVariantMap m_signalControl;
    QVariantMap m_systemHealth;
    QVariantMap m_monitorUi;
    QVariantMap m_robotTelemetry;

    QFileSystemWatcher m_watcher;
    QTimer m_reloadTimer;
    QSet<QString> m_pendingReloadFiles;
};

#endif // DATAMANAGER_H
