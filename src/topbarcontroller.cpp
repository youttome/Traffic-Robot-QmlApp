#include "include/topbarcontroller.h"

TopBarController::TopBarController(QObject *parent)
    : QObject(parent), m_missionTime("00:00:00"), m_latency(0), m_signalStrength(3), m_seconds(0)
{
    // Mission timer - updates every second
    m_missionTimer = new QTimer(this);
    connect(m_missionTimer, &QTimer::timeout, this, &TopBarController::updateMissionTime);
    m_missionTimer->start(1000);

    // Latency simulator - updates every 500ms
    m_latencyTimer = new QTimer(this);
    connect(m_latencyTimer, &QTimer::timeout, this, &TopBarController::simulateLatency);
    m_latencyTimer->start(500);

    // Signal strength simulator - updates every 2 seconds
    m_signalTimer = new QTimer(this);
    connect(m_signalTimer, &QTimer::timeout, this, &TopBarController::simulateSignalStrength);
    m_signalTimer->start(2000);
}

QString TopBarController::missionTime() const
{
    return m_missionTime;
}

void TopBarController::setMissionTime(const QString &time)
{
    if (m_missionTime != time) {
        m_missionTime = time;
        emit missionTimeChanged();
    }
}

int TopBarController::latency() const
{
    return m_latency;
}

void TopBarController::setLatency(int ms)
{
    if (m_latency != ms) {
        m_latency = ms;
        emit latencyChanged();
    }
}

int TopBarController::signalStrength() const
{
    return m_signalStrength;
}

void TopBarController::setSignalStrength(int strength)
{
    if (m_signalStrength != strength) {
        // Clamp value between 0 and 4
        m_signalStrength = qBound(0, strength, 4);
        emit signalStrengthChanged();
    }
}

void TopBarController::updateMissionTime()
{
    m_seconds++;
    int hours = m_seconds / 3600;
    int minutes = (m_seconds % 3600) / 60;
    int seconds = m_seconds % 60;

    setMissionTime(QString("%1:%2:%3")
                       .arg(hours, 2, 10, QChar('0'))
                       .arg(minutes, 2, 10, QChar('0'))
                       .arg(seconds, 2, 10, QChar('0')));
}

void TopBarController::simulateLatency()
{
    // Simulate random latency between 5-50ms
    int newLatency = 5 + (rand() % 46);
    setLatency(newLatency);
}

void TopBarController::simulateSignalStrength()
{
    // Simulate random signal strength between 1-4
    int newStrength = 1 + (rand() % 4);
    setSignalStrength(newStrength);
}
