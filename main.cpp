#include <QGuiApplication>
#include <QDateTime>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "systemmonitor.h"
#include "include/topbarcontroller.h"
#include <camera.h>
#include <datamanager.h>
#include <rosstreammanager.h>

#if APP_HAS_ROS2
#include <rclcpp/rclcpp.hpp>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

#if APP_HAS_ROS2
    if (!rclcpp::ok()) {
        rclcpp::init(argc, argv);
    }
#endif

    DataManager dataManager;
    QObject::connect(&dataManager, &DataManager::errorOccurred, &app, [](const QString &error) {
        qWarning() << error;
    });

    const QString databasePath = qEnvironmentVariable(
        "MONITOR_APP_DB_PATH",
        "/media/abso/project/database/monitor_app");
    dataManager.setDatabasePath(databasePath);

    SystemMonitor systemMonitor;
    TopBarController controller;
    RosStreamManager rosStreams;

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("dataManager", &dataManager);
    engine.rootContext()->setContextProperty("systemMonitor", &systemMonitor);
    engine.rootContext()->setContextProperty("rosStreams", &rosStreams);

    const auto pushTelemetry = [&dataManager, &systemMonitor]() {
        dataManager.patchSystemHealth({
            {"cpuUsage", qRound(systemMonitor.performanceValue() * 100.0)},
            {"battery", systemMonitor.batteryValue()},
            {"lastUpdated", QDateTime::currentSecsSinceEpoch()},
        });
    };

    QObject::connect(&systemMonitor, &SystemMonitor::performanceValueChanged, &dataManager, pushTelemetry);
    QObject::connect(&systemMonitor, &SystemMonitor::batteryValueChanged, &dataManager, pushTelemetry);
    pushTelemetry();

    engine.rootContext()->setContextProperty("topBarData", &controller);

    CameraProvider *provider = new CameraProvider();
    engine.addImageProvider("camera", provider);
    engine.addImageProvider("roscam", new RosStreamImageProvider(&rosStreams));

    engine.loadFromModule("CircleBarsUI", "Main");
    // Enable this for 100 circlebars example
    //engine.loadFromModule("CircleBarsUI", "Main50CircleBars");

    const int exitCode = app.exec();

#if APP_HAS_ROS2
    if (rclcpp::ok()) {
        rclcpp::shutdown();
    }
#endif

    return exitCode;
}
