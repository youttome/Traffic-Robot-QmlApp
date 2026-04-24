import QtQuick
import QtQuick.Layouts
import QtLocation
import QtPositioning

Rectangle {
    id: root

    property color accentColor: "#5fc9d9"
    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var mapUi: uiData.map || ({})
    readonly property var telemetryData: dataManager.robotTelemetry || ({})
    readonly property int eventCount: dataManager.trafficViolations ? dataManager.trafficViolations.length : 0
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property real latValue: telemetryData.lat !== undefined ? Number(telemetryData.lat) : 30.60291
    readonly property real lonValue: telemetryData.lon !== undefined ? Number(telemetryData.lon) : 32.30487
    readonly property real zoomValue: telemetryData.zoom !== undefined
        ? Number(telemetryData.zoom)
        : (mapUi.zoomLevel !== undefined ? Number(mapUi.zoomLevel) : 16)

    color: "#091019"
    border.color: "#1f2d35"
    border.width: 1
    radius: 10

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: mapUi.title || "LIVE STREET MAP"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: mapUi.subtitle || "Intersection overview and route intelligence"
                    color: "#7a8d9e"
                    font.pixelSize: 10
                }
            }

            Rectangle {
                radius: 8
                color: "#0f1822"
                border.color: root.accentColor
                border.width: 1
                Layout.preferredWidth: 84
                Layout.preferredHeight: 28

                Text {
                    anchors.centerIn: parent
                    text: root.eventCount + " " + (mapUi.eventSuffix || "EVENTS")
                    color: root.accentColor
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            border.color: "#16212b"
            border.width: 1
            clip: true

            Map {
                id: map
                anchors.fill: parent
                plugin: mapPlugin
                zoomLevel: root.zoomValue
                center: QtPositioning.coordinate(root.latValue, root.lonValue)
                activeMapType: supportedMapTypes.length > 0 ? supportedMapTypes[0] : null

                MapCircle {
                    center: QtPositioning.coordinate(root.latValue, root.lonValue)
                    radius: 60
                    color: "#33ff5555"
                    border.color: "#ff4d4d"
                    border.width: 2
                }

                MapQuickItem {
                    coordinate: QtPositioning.coordinate(root.latValue, root.lonValue)
                    anchorPoint.x: icon.width / 2
                    anchorPoint.y: icon.height / 2

                    sourceItem: Rectangle {
                        id: icon
                        width: 22
                        height: 22
                        radius: 11
                        color: "#e74c3c"
                        border.color: "white"
                        border.width: 2
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 10
                radius: 6
                color: "#a0000000"
                border.color: "#27404f"
                border.width: 1
                width: 180
                height: 54

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        text: mapUi.telemetryTitle || telemetryData.label || "ROBOT TELEMETRY"
                        color: "white"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        text: "LAT " + root.latValue.toFixed(5)
                        color: "#7fd9e8"
                        font.pixelSize: 10
                    }

                    Text {
                        text: "LON " + root.lonValue.toFixed(5)
                        color: "#7fd9e8"
                        font.pixelSize: 10
                    }

                    Text {
                        text: (telemetryData.routeState || "Intersection standby")
                            + "  |  CPU " + (root.systemHealthData.cpuUsage !== undefined ? root.systemHealthData.cpuUsage : 0) + "%"
                        color: "#d8e6f2"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
