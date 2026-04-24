
#pragma once

#include <QObject>
#include <QThread>
#include <QImage>
#include <QMutex>
#include <QQuickImageProvider>
#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/logger.hpp>

class Camera : public QThread
{
    Q_OBJECT
public:
    explicit Camera(QObject *parent = nullptr);
    ~Camera() override;
    void run() override;
    void stop();

signals:
    void frameReady(const QImage &frame);

private:
    bool running = true;
};

class CameraProvider : public QQuickImageProvider
{
    Q_OBJECT
public:
    CameraProvider();
    ~CameraProvider() override;
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    Camera *camera;
    QImage currentFrame;
    QMutex frameMutex;
};
