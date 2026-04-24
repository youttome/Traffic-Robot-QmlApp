#include "systemmonitor.h"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent)
    , m_performanceValue(0.0)
    , m_batteryValue(80)
    , m_firstCpuRead(true)
{
    // Initialize CPU stats
    m_prevCpuStats = {0, 0, 0, 0, 0, 0, 0};

    // Performance update timer (CPU usage) - every 1 second
    m_performanceTimer.setInterval(1000);
    connect(&m_performanceTimer, &QTimer::timeout, this, &SystemMonitor::updatePerformance);
    m_performanceTimer.start();

    // Battery update timer - every 5 seconds
    m_batteryTimer.setInterval(5000);
    connect(&m_batteryTimer, &QTimer::timeout, this, &SystemMonitor::updateBattery);
    m_batteryTimer.start();

    // Initial readings
    updatePerformance();
    updateBattery();
}

qreal SystemMonitor::performanceValue() const
{
    return m_performanceValue;
}

int SystemMonitor::batteryValue() const
{
    return m_batteryValue;
}

void SystemMonitor::updatePerformance()
{
    CpuStats current = readCpuStats();

    if (!m_firstCpuRead) {
        qreal cpuUsage = calculateCpuUsage(current, m_prevCpuStats);
        // Normalize to 0.0-1.0 range for performance_value
        m_performanceValue = qBound(0.0, cpuUsage / 100.0, 1.0);
        emit performanceValueChanged();
    } else {
        m_firstCpuRead = false;
    }

    m_prevCpuStats = current;
}

void SystemMonitor::updateBattery()
{
    int batteryLevel = readBatteryLevel();
    if (batteryLevel != m_batteryValue) {
        m_batteryValue = batteryLevel;
        emit batteryValueChanged();
    }
}

SystemMonitor::CpuStats SystemMonitor::readCpuStats()
{
    CpuStats stats = {0, 0, 0, 0, 0, 0, 0};

    QFile file("/proc/stat");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString line = in.readLine();

        if (line.startsWith("cpu ")) {
            QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
            if (parts.size() >= 8) {
                stats.user = parts[1].toULongLong();
                stats.nice = parts[2].toULongLong();
                stats.system = parts[3].toULongLong();
                stats.idle = parts[4].toULongLong();
                stats.iowait = parts[5].toULongLong();
                stats.irq = parts[6].toULongLong();
                stats.softirq = parts[7].toULongLong();
            }
        }
        file.close();
    }

    return stats;
}

qreal SystemMonitor::calculateCpuUsage(const CpuStats& current, const CpuStats& previous)
{
    unsigned long long prevTotal = previous.user + previous.nice + previous.system +
                                   previous.idle + previous.iowait + previous.irq + previous.softirq;
    unsigned long long currTotal = current.user + current.nice + current.system +
                                   current.idle + current.iowait + current.irq + current.softirq;

    unsigned long long totalDiff = currTotal - prevTotal;
    unsigned long long idleDiff = current.idle - previous.idle;

    if (totalDiff == 0) return 0.0;

    qreal usage = 100.0 * (totalDiff - idleDiff) / totalDiff;
    return qBound(0.0, usage, 100.0);
}

int SystemMonitor::readBatteryLevel()
{
    // Try different battery paths (common on Linux systems)
    QStringList batteryPaths = {
        "/sys/class/power_supply/BAT0/capacity",
        "/sys/class/power_supply/BAT1/capacity",
        "/sys/class/power_supply/BAT2/capacity"
    };

    for (const QString& path : batteryPaths) {
        QFile file(path);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&file);
            QString content = in.readAll().trimmed();
            file.close();

            bool ok;
            int level = content.toInt(&ok);
            if (ok) {
                return qBound(0, level, 100);
            }
        }
    }

    // Fallback: return current value if battery not found
    qWarning() << "Could not read battery level from /sys/class/power_supply/BAT*/capacity";
    return m_batteryValue;
}