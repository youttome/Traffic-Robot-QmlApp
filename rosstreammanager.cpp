#include "rosstreammanager.h"

#include <QDateTime>
#include <QMutexLocker>
#include <QPainter>
#include <QSize>

#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

namespace {
QImage placeholderFrame(const QString &title, const QString &topic, const QSize &requestedSize = QSize())
{
    const QSize size = requestedSize.isValid() ? requestedSize : QSize(640, 360);
    QImage image(size, QImage::Format_ARGB32_Premultiplied);
    image.fill(QColor("#0b1017"));

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.fillRect(image.rect(), QColor("#0b1017"));

    painter.setPen(QPen(QColor("#5fc9d9"), 2));
    painter.drawRoundedRect(image.rect().adjusted(10, 10, -10, -10), 18, 18);

    painter.setPen(QColor("#5fc9d9"));
    QFont titleFont = painter.font();
    titleFont.setBold(true);
    titleFont.setPixelSize(24);
    painter.setFont(titleFont);
    painter.drawText(image.rect().adjusted(20, 40, -20, -20), Qt::AlignHCenter | Qt::AlignTop, title);

    painter.setPen(QColor("#d7e0ea"));
    QFont bodyFont = painter.font();
    bodyFont.setPixelSize(16);
    bodyFont.setBold(false);
    painter.setFont(bodyFont);
    painter.drawText(
        image.rect().adjusted(30, 110, -30, -30),
        Qt::AlignHCenter | Qt::TextWordWrap,
        QStringLiteral("Waiting for ROS topic\n%1").arg(topic));

    return image;
}

QImage imageFromMat(const cv::Mat &mat)
{
    if (mat.empty()) {
        return {};
    }

    if (mat.type() == CV_8UC3) {
        cv::Mat rgb;
        cv::cvtColor(mat, rgb, cv::COLOR_BGR2RGB);
        return QImage(rgb.data, rgb.cols, rgb.rows, rgb.step, QImage::Format_RGB888).copy();
    }

    if (mat.type() == CV_8UC1) {
        return QImage(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_Grayscale8).copy();
    }

    if (mat.type() == CV_8UC4) {
        return QImage(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_RGBA8888).copy();
    }

    return {};
}
} // namespace

RosStreamManager::RosStreamManager(QObject *parent)
    : QObject(parent)
    , m_robotTopic(topicFromEnvironment("MONITOR_CAM_ROBOT_TOPIC", "/cam_robot"))
    , m_streetATopic(topicFromEnvironment("MONITOR_CAM_A_TOPIC", "/cam_A"))
    , m_streetBTopic(topicFromEnvironment("MONITOR_CAM_B_TOPIC", "/cma_B"))
    , m_aiTopic(topicFromEnvironment("MONITOR_STREET_AI_TOPIC", "/street_ai_monitor"))
    , m_aiSummary(QStringLiteral("Waiting for AI summary on %1").arg(m_aiTopic))
{
    initializePlaceholders();

    m_refreshTimer.setInterval(1000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &RosStreamManager::refreshStreamStates);
    m_refreshTimer.start();

#if APP_HAS_ROS2
    setupRosSubscriptions();
#endif
}

RosStreamManager::~RosStreamManager()
{
#if APP_HAS_ROS2
    if (m_executor && m_node) {
        m_executor->cancel();
        m_executor->remove_node(m_node);
    }
    if (m_spinThread.joinable()) {
        m_spinThread.join();
    }
#endif
}

bool RosStreamManager::rosAvailable() const
{
#if APP_HAS_ROS2
    return true;
#else
    return false;
#endif
}

QString RosStreamManager::robotTopic() const
{
    return m_robotTopic;
}

QString RosStreamManager::streetATopic() const
{
    return m_streetATopic;
}

QString RosStreamManager::streetBTopic() const
{
    return m_streetBTopic;
}

QString RosStreamManager::aiTopic() const
{
    return m_aiTopic;
}

bool RosStreamManager::robotOnline() const
{
    return onlineFor("robot");
}

bool RosStreamManager::streetAOnline() const
{
    return onlineFor("streetA");
}

bool RosStreamManager::streetBOnline() const
{
    return onlineFor("streetB");
}

bool RosStreamManager::aiOnline() const
{
    return m_aiOnline;
}

int RosStreamManager::robotFps() const
{
    return fpsFor("robot");
}

int RosStreamManager::streetAFps() const
{
    return fpsFor("streetA");
}

int RosStreamManager::streetBFps() const
{
    return fpsFor("streetB");
}

QString RosStreamManager::robotSignal() const
{
    return signalFor("robot");
}

QString RosStreamManager::streetASignal() const
{
    return signalFor("streetA");
}

QString RosStreamManager::streetBSignal() const
{
    return signalFor("streetB");
}

QString RosStreamManager::aiSummary() const
{
    return m_aiSummary;
}

QString RosStreamManager::topicFromEnvironment(const QString &envName, const QString &fallback) const
{
    return qEnvironmentVariable(envName.toUtf8().constData(), fallback.toUtf8().constData());
}

void RosStreamManager::initializePlaceholders()
{
    QMutexLocker locker(&m_mutex);
    m_streams.insert("robot", StreamState{"robot", m_robotTopic, "ROBOT CAM", placeholderFrame("ROBOT CAM", m_robotTopic)});
    m_streams.insert("streetA", StreamState{"streetA", m_streetATopic, "STREET A CAM", placeholderFrame("STREET A CAM", m_streetATopic)});
    m_streams.insert("streetB", StreamState{"streetB", m_streetBTopic, "STREET B CAM", placeholderFrame("STREET B CAM", m_streetBTopic)});
}

QString RosStreamManager::signalFor(const QString &streamId) const
{
    return onlineFor(streamId) ? QStringLiteral("LIVE") : QStringLiteral("WAITING");
}

bool RosStreamManager::onlineFor(const QString &streamId) const
{
    QMutexLocker locker(&m_mutex);
    return m_streams.value(streamId).online;
}

int RosStreamManager::fpsFor(const QString &streamId) const
{
    QMutexLocker locker(&m_mutex);
    return m_streams.value(streamId).fps;
}

QString RosStreamManager::topicFor(const QString &streamId) const
{
    QMutexLocker locker(&m_mutex);
    return m_streams.value(streamId).topic;
}

QImage RosStreamManager::frameFor(const QString &streamId, const QSize &requestedSize) const
{
    QMutexLocker locker(&m_mutex);
    const auto stream = m_streams.value(streamId);
    if (stream.frame.isNull()) {
        return placeholderFrame(stream.title, stream.topic, requestedSize);
    }

    if (!requestedSize.isValid()) {
        return stream.frame;
    }

    return stream.frame.scaled(
        requestedSize,
        Qt::KeepAspectRatioByExpanding,
        Qt::SmoothTransformation);
}

QImage RosStreamManager::requestFrame(const QString &streamId, QSize *size, const QSize &requestedSize) const
{
    const QImage frame = frameFor(streamId, requestedSize);
    if (size) {
        *size = frame.size();
    }
    return frame;
}

void RosStreamManager::updateStreamFrame(const QString &streamId, const QImage &frame)
{
    if (frame.isNull()) {
        return;
    }

    QMutexLocker locker(&m_mutex);
    auto it = m_streams.find(streamId);
    if (it == m_streams.end()) {
        return;
    }

    it->frame = frame;
    it->lastFrameMs = QDateTime::currentMSecsSinceEpoch();
    it->pendingFrames += 1;
}

void RosStreamManager::updateAiSummary(const QString &summary)
{
    QMetaObject::invokeMethod(this, [this, summary]() {
        m_aiSummary = summary;
        m_aiOnline = true;
        m_lastAiMessageMs = QDateTime::currentMSecsSinceEpoch();
        emit aiSummaryChanged();
    }, Qt::QueuedConnection);
}

void RosStreamManager::refreshStreamStates()
{
    const qint64 nowMs = QDateTime::currentMSecsSinceEpoch();
    bool streamChanged = false;

    {
        QMutexLocker locker(&m_mutex);
        for (auto it = m_streams.begin(); it != m_streams.end(); ++it) {
            const bool nextOnline = it->lastFrameMs > 0 && (nowMs - it->lastFrameMs) < 2000;
            const int nextFps = it->pendingFrames;
            if (it->online != nextOnline || it->fps != nextFps) {
                streamChanged = true;
            }
            it->online = nextOnline;
            it->fps = nextFps;
            it->pendingFrames = 0;
        }
    }

    const bool nextAiOnline = m_lastAiMessageMs > 0 && (nowMs - m_lastAiMessageMs) < 3000;
    if (nextAiOnline != m_aiOnline) {
        m_aiOnline = nextAiOnline;
        emit aiSummaryChanged();
    }

    if (streamChanged) {
        emit streamInfoChanged();
    }
}

#if APP_HAS_ROS2
namespace {
QImage imageFromRosMessage(const sensor_msgs::msg::Image &message)
{
    const int width = static_cast<int>(message.width);
    const int height = static_cast<int>(message.height);
    const int step = static_cast<int>(message.step);
    const uchar *data = reinterpret_cast<const uchar *>(message.data.data());

    if (message.encoding == "rgb8") {
        return QImage(data, width, height, step, QImage::Format_RGB888).copy();
    }
    if (message.encoding == "bgr8") {
        return QImage(data, width, height, step, QImage::Format_RGB888).rgbSwapped().copy();
    }
    if (message.encoding == "rgba8") {
        return QImage(data, width, height, step, QImage::Format_RGBA8888).copy();
    }
    if (message.encoding == "bgra8") {
        return QImage(data, width, height, step, QImage::Format_ARGB32).rgbSwapped().copy();
    }
    if (message.encoding == "mono8") {
        return QImage(data, width, height, step, QImage::Format_Grayscale8).copy();
    }

    return {};
}
} // namespace

void RosStreamManager::setupRosSubscriptions()
{
    m_node = std::make_shared<rclcpp::Node>("circlebars_ui_ros_streams");
    m_executor = std::make_shared<rclcpp::executors::SingleThreadedExecutor>();
    m_executor->add_node(m_node);

    const auto qos = rclcpp::SensorDataQoS();
    const QList<QPair<QString, QString>> streams = {
        {"robot", m_robotTopic},
        {"streetA", m_streetATopic},
        {"streetB", m_streetBTopic},
    };

    for (const auto &stream : streams) {
        const std::string topic = stream.second.toStdString();
        const QString streamId = stream.first;

        m_imageSubscriptions.push_back(
            m_node->create_subscription<sensor_msgs::msg::Image>(
                topic,
                qos,
                [this, streamId](const sensor_msgs::msg::Image::SharedPtr message) {
                    handleImageMessage(streamId, *message);
                }));

        m_compressedSubscriptions.push_back(
            m_node->create_subscription<sensor_msgs::msg::CompressedImage>(
                topic + "/compressed",
                qos,
                [this, streamId](const sensor_msgs::msg::CompressedImage::SharedPtr message) {
                    handleCompressedImageMessage(streamId, *message);
                }));
    }

    m_aiSubscription = m_node->create_subscription<std_msgs::msg::String>(
        m_aiTopic.toStdString(),
        10,
        [this](const std_msgs::msg::String::SharedPtr message) {
            updateAiSummary(QString::fromStdString(message->data));
        });

    m_spinThread = std::thread([this]() {
        m_executor->spin();
    });
}

void RosStreamManager::handleImageMessage(const QString &streamId, const sensor_msgs::msg::Image &message)
{
    const QImage frame = imageFromRosMessage(message);
    if (!frame.isNull()) {
        updateStreamFrame(streamId, frame);
    }
}

void RosStreamManager::handleCompressedImageMessage(const QString &streamId, const sensor_msgs::msg::CompressedImage &message)
{
    const cv::Mat encoded(1, static_cast<int>(message.data.size()), CV_8UC1, const_cast<unsigned char *>(message.data.data()));
    const cv::Mat decoded = cv::imdecode(encoded, cv::IMREAD_COLOR);
    const QImage frame = imageFromMat(decoded);
    if (!frame.isNull()) {
        updateStreamFrame(streamId, frame);
    }
}
#endif

RosStreamImageProvider::RosStreamImageProvider(RosStreamManager *streamManager)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_streamManager(streamManager)
{
}

QImage RosStreamImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return m_streamManager->requestFrame(id, size, requestedSize);
}
