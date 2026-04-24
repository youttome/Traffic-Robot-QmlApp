#ifndef SYSTEMMONITOR_H
#define SYSTEMMONITOR_H

#include <QObject>
#include <QTimer>
#include <QFile>
#include <QRegularExpression>

class SystemMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal performanceValue READ performanceValue NOTIFY performanceValueChanged)
    Q_PROPERTY(int batteryValue READ batteryValue NOTIFY batteryValueChanged)

public:
    explicit SystemMonitor(QObject *parent = nullptr);

    qreal performanceValue() const;
    int batteryValue() const;

signals:
    void performanceValueChanged();
    void batteryValueChanged();

private slots:
    void updatePerformance();
    void updateBattery();

private:
    struct CpuStats {
        unsigned long long user;
        unsigned long long nice;
        unsigned long long system;
        unsigned long long idle;
        unsigned long long iowait;
        unsigned long long irq;
        unsigned long long softirq;
    };

    CpuStats readCpuStats();
    qreal calculateCpuUsage(const CpuStats& current, const CpuStats& previous);
    int readBatteryLevel();

    qreal m_performanceValue;
    int m_batteryValue;
    CpuStats m_prevCpuStats;
    bool m_firstCpuRead;
    QTimer m_performanceTimer;
    QTimer m_batteryTimer;
};

#endif // SYSTEMMONITOR_H