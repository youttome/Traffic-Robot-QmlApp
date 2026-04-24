#pragma once

#include <QHash>
#include <QImage>
#include <QMutex>
#include <QObject>
#include <QQuickImageProvider>
#include <QTimer>
#include <thread>
#include <vector>

#if APP_HAS_ROS2
#include <rclcpp/rclcpp.hpp>
#include <sensor_msgs/msg/compressed_image.hpp>
#include <sensor_msgs/msg/image.hpp>
#include <std_msgs/msg/string.hpp>
#endif

class RosStreamManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool rosAvailable READ rosAvailable CONSTANT)
    Q_PROPERTY(QString robotTopic READ robotTopic CONSTANT)
    Q_PROPERTY(QString streetATopic READ streetATopic CONSTANT)
    Q_PROPERTY(QString streetBTopic READ streetBTopic CONSTANT)
    Q_PROPERTY(QString aiTopic READ aiTopic CONSTANT)
    Q_PROPERTY(bool robotOnline READ robotOnline NOTIFY streamInfoChanged)
    Q_PROPERTY(bool streetAOnline READ streetAOnline NOTIFY streamInfoChanged)
    Q_PROPERTY(bool streetBOnline READ streetBOnline NOTIFY streamInfoChanged)
    Q_PROPERTY(bool aiOnline READ aiOnline NOTIFY aiSummaryChanged)
    Q_PROPERTY(int robotFps READ robotFps NOTIFY streamInfoChanged)
    Q_PROPERTY(int streetAFps READ streetAFps NOTIFY streamInfoChanged)
    Q_PROPERTY(int streetBFps READ streetBFps NOTIFY streamInfoChanged)
    Q_PROPERTY(QString robotSignal READ robotSignal NOTIFY streamInfoChanged)
    Q_PROPERTY(QString streetASignal READ streetASignal NOTIFY streamInfoChanged)
    Q_PROPERTY(QString streetBSignal READ streetBSignal NOTIFY streamInfoChanged)
    Q_PROPERTY(QString aiSummary READ aiSummary NOTIFY aiSummaryChanged)

public:
    explicit RosStreamManager(QObject *parent = nullptr);
    ~RosStreamManager() override;

    bool rosAvailable() const;

    QString robotTopic() const;
    QString streetATopic() const;
    QString streetBTopic() const;
    QString aiTopic() const;

    bool robotOnline() const;
    bool streetAOnline() const;
    bool streetBOnline() const;
    bool aiOnline() const;

    int robotFps() const;
    int streetAFps() const;
    int streetBFps() const;

    QString robotSignal() const;
    QString streetASignal() const;
    QString streetBSignal() const;
    QString aiSummary() const;

    QImage requestFrame(const QString &streamId, QSize *size, const QSize &requestedSize) const;

signals:
    void streamInfoChanged();
    void aiSummaryChanged();

private slots:
    void refreshStreamStates();

private:
    struct StreamState {
        QString id;
        QString topic;
        QString title;
        QImage frame;
        bool online = false;
        int fps = 0;
        int pendingFrames = 0;
        qint64 lastFrameMs = 0;
    };

    QString topicFromEnvironment(const QString &envName, const QString &fallback) const;
    QString signalFor(const QString &streamId) const;
    bool onlineFor(const QString &streamId) const;
    int fpsFor(const QString &streamId) const;
    QString topicFor(const QString &streamId) const;
    QImage frameFor(const QString &streamId, const QSize &requestedSize) const;
    void updateStreamFrame(const QString &streamId, const QImage &frame);
    void updateAiSummary(const QString &summary);
    void initializePlaceholders();

#if APP_HAS_ROS2
    void setupRosSubscriptions();
    void handleImageMessage(const QString &streamId, const sensor_msgs::msg::Image &message);
    void handleCompressedImageMessage(const QString &streamId, const sensor_msgs::msg::CompressedImage &message);
#endif

    mutable QMutex m_mutex;
    QHash<QString, StreamState> m_streams;
    QString m_robotTopic;
    QString m_streetATopic;
    QString m_streetBTopic;
    QString m_aiTopic;
    QString m_aiSummary;
    bool m_aiOnline = false;
    qint64 m_lastAiMessageMs = 0;
    QTimer m_refreshTimer;

#if APP_HAS_ROS2
    std::shared_ptr<rclcpp::Node> m_node;
    std::shared_ptr<rclcpp::executors::SingleThreadedExecutor> m_executor;
    std::thread m_spinThread;
    std::vector<rclcpp::Subscription<sensor_msgs::msg::Image>::SharedPtr> m_imageSubscriptions;
    std::vector<rclcpp::Subscription<sensor_msgs::msg::CompressedImage>::SharedPtr> m_compressedSubscriptions;
    rclcpp::Subscription<std_msgs::msg::String>::SharedPtr m_aiSubscription;
#endif
};

class RosStreamImageProvider : public QQuickImageProvider
{
public:
    explicit RosStreamImageProvider(RosStreamManager *streamManager);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    RosStreamManager *m_streamManager;
};
