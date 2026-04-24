import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

Item {
    id: root

    // expose size
    width: 1400
    height: 900

    property bool nightMode: true
    property color neonBlue: "#00eaff"
    property color neonOrange: "#ff8c00"
    property color neonPurple: "#bc13fe"
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property int violationCount: dataManager.trafficViolations ? dataManager.trafficViolations.length : 0
    readonly property int trafficLevel: violationCount > 5 ? 2 : (violationCount > 2 ? 1 : 0)

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: mainMap
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 17
        activeMapType: mainMap.supportedMapTypes.length > 0
            ? mainMap.supportedMapTypes[0]
            : null

        center: QtPositioning.coordinate(30.60291, 32.30487)

        MapPolyline {
            id: pathLine
            line.width: 6
            line.color: root.trafficLevel === 0 ? "#39ff14"
                        : root.trafficLevel === 1 ? "#ffff00"
                        : "#ff0000"
            opacity: 0.7
            path: []
        }

        MapQuickItem {
            id: robotMarker
            coordinate: mainMap.center
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2

            sourceItem: Item {
                width: 100; height: 100

                Rectangle {
                    anchors.centerIn: parent
                    width: 60; height: 60
                    radius: 30
                    color: "transparent"
                    border.color: "red"
                    border.width: 2

                    PropertyAnimation on scale {
                        from: 1.0; to: 1.8
                        duration: 1500
                        loops: Animation.Infinite
                    }
                    PropertyAnimation on opacity {
                        from: 1.0; to: 0.0
                        duration: 1500
                        loops: Animation.Infinite
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 40; height: 40
                    radius: 20
                    color: "#ccff0000"

                    Text {
                        anchors.centerIn: parent
                        text: "🤖"
                        font.pixelSize: 24
                    }
                }
            }
        }
    }

    // CAMERA
    Rectangle {
        id: cameraInset
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12

        width: 320
        height: 190
        radius: 12
        color: "#0f141a"   // أغمق شوية (احترافي)

        border.color: "#39ff14"
        border.width: 1.5

        clip: true

        // 🔥 subtle glow (خفيف مش تقيل)
        layer.enabled: true
        layer.smooth: true

        // ===== CAMERA VIEW =====
        Image {
            id: cam
            anchors.fill: parent

            fillMode: Image.PreserveAspectCrop   // 🔥 يملأ المستطيل بالكامل
            smooth: true
            cache: false   // مهم للـ live feed
            source: "image://camera/frame"
        }

        // ===== DARK OVERLAY (cinematic look) =====
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.15
        }

        // ===== TOP LABEL =====
        Text {
            text: "LIVE"
            color: "#39ff14"
            font.pixelSize: 12
            font.bold: true

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8
        }

        // ===== RECORD DOT =====
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: "red"

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 8

            anchors.leftMargin: 40
        }

        // ===== FPS TEXT =====
        Text {
            id: fpsText
            text: cam.status === Image.Error ? "OFFLINE" : "LIVE FEED"
            color: "#cccccc"
            font.pixelSize: 10

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 6
        }

        // ===== FRAME UPDATE =====
        Timer {
            interval: 250
            running: true
            repeat: true

            onTriggered: {
                cam.source = "image://camera/frame?" + Date.now()
            }
        }
    }

    // DATA PANEL
    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: 180
        height: 120
        color: "#cc000000"
        border.color: neonBlue
        border.width: 1
        radius: 15

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 5

            Text {
                text: "ROBOT TELEMETRY"
                color: neonBlue
                font.bold: true
                font.pixelSize: 15
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: neonBlue
                opacity: 0.5
            }

            Text {
                text: "LAT: " + mainMap.center.latitude.toFixed(6)
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "LON: " + mainMap.center.longitude.toFixed(6)
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "CPU: " + (systemHealthData.cpuUsage !== undefined ? systemHealthData.cpuUsage : 0) + "%"
                color: "white"
                font.family: "Monospace"
            }

            Text {
                text: "BAT: " + (systemHealthData.battery !== undefined ? systemHealthData.battery : 0) + "%"
                color: "white"
                font.family: "Monospace"
            }

            Row {
                spacing: 10

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#39ff14"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: violationCount > 0 ? violationCount + " ACTIVE EVENTS" : "SYSTEM ACTIVE"
                    color: root.trafficLevel === 2 ? "#ff6b6b" : "#39ff14"
                    font.pixelSize: 12
                }
            }
        }
    }
}
