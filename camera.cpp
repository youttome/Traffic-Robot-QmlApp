#include "camera.h"

#include <QFileInfo>
#include <QMutexLocker>
#include <QPainter>

namespace {
QImage makePlaceholderFrame(const QSize &requestedSize = QSize())
{
    const QSize size = requestedSize.isValid() ? requestedSize : QSize(640, 360);
    QImage image(size, QImage::Format_ARGB32_Premultiplied);
    image.fill(QColor("#0f141a"));

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing, true);

    painter.fillRect(image.rect(), QColor("#0f141a"));
    painter.setPen(QPen(QColor("#39ff14"), 2));
    painter.drawRoundedRect(image.rect().adjusted(8, 8, -8, -8), 16, 16);

    painter.setPen(QColor("#39ff14"));
    QFont titleFont = painter.font();
    titleFont.setBold(true);
    titleFont.setPixelSize(28);
    painter.setFont(titleFont);
    painter.drawText(image.rect().adjusted(24, 60, -24, -60), Qt::AlignHCenter | Qt::AlignTop, "CAMERA OFFLINE");

    painter.setPen(QColor("#a0b8a0"));
    QFont bodyFont = painter.font();
    bodyFont.setBold(false);
    bodyFont.setPixelSize(16);
    painter.setFont(bodyFont);
    painter.drawText(
        image.rect().adjusted(24, 120, -24, -40),
        Qt::AlignHCenter | Qt::TextWordWrap,
        "No video device is available on /dev/video0.\nThe dashboard is still running and live JSON sync remains active.");

    return image;
}
} // namespace

Camera::Camera(QObject *parent)
    : QThread(parent)
{
}

Camera::~Camera()
{
    stop();
}

void Camera::run()
{
    cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_ERROR);

    if (!QFileInfo::exists("/dev/video0")) {
        return;
    }

    cv::VideoCapture cap;
    cap.open(0, cv::CAP_V4L2);

    if (!cap.isOpened()) {
        return;
    }

    cv::Mat frame;

    while (running) {
        cap >> frame;
        if (frame.empty()) {
            msleep(30);
            continue;
        }

        cv::cvtColor(frame, frame, cv::COLOR_BGR2RGB);

        QImage img(
            frame.data,
            frame.cols,
            frame.rows,
            frame.step,
            QImage::Format_RGB888);

        emit frameReady(img.copy());
        msleep(30);
    }
}

void Camera::stop()
{
    if (!isRunning()) {
        return;
    }

    running = false;
    wait();
}

CameraProvider::CameraProvider()
    : QQuickImageProvider(Image)
    , camera(new Camera(this))
    , currentFrame(makePlaceholderFrame())
{
    connect(camera, &Camera::frameReady, this, [this](const QImage &frame) {
        QMutexLocker locker(&frameMutex);
        currentFrame = frame;
    });

    camera->start();
}

CameraProvider::~CameraProvider()
{
    camera->stop();
}

QImage CameraProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(id);

    QMutexLocker locker(&frameMutex);
    if (currentFrame.isNull()) {
        currentFrame = makePlaceholderFrame(requestedSize);
    }

    QImage image = currentFrame;
    if (requestedSize.isValid() && image.size() != requestedSize) {
        image = image.scaled(requestedSize, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation);
    }

    if (size) {
        *size = image.size();
    }

    return image;
}
