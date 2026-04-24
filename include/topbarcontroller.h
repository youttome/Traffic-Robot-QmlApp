#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

class TopBarController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString missionTime READ missionTime WRITE setMissionTime NOTIFY missionTimeChanged)
    Q_PROPERTY(int latency READ latency WRITE setLatency NOTIFY latencyChanged)
    Q_PROPERTY(int signalStrength READ signalStrength WRITE setSignalStrength NOTIFY signalStrengthChanged)

public:
    explicit TopBarController(QObject *parent = nullptr);

    QString missionTime() const;
    void setMissionTime(const QString &time);

    int latency() const;
    void setLatency(int ms);

    int signalStrength() const;
    void setSignalStrength(int strength);

signals:
    void missionTimeChanged();
    void latencyChanged();
    void signalStrengthChanged();

private slots:
    void updateMissionTime();
    void simulateLatency();
    void simulateSignalStrength();

private:
    QString m_missionTime;
    int m_latency;
    int m_signalStrength;
    QTimer *m_missionTimer;
    QTimer *m_latencyTimer;
    QTimer *m_signalTimer;
    int m_seconds;
};
