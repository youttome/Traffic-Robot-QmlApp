import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root

    // 🔥 Responsive Scale System
    property real scaleW: width / 400
    property real scaleH: height / 800
    property real scale: Math.min(scaleW, scaleH)
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property int batteryLevel: systemHealthData.battery !== undefined
        ? Number(systemHealthData.battery)
        : (typeof battery_value !== "undefined" ? battery_value : 0)
    readonly property int temperature: systemHealthData.temperature !== undefined
        ? Number(systemHealthData.temperature)
        : 25
    readonly property int memoryUsage: systemHealthData.memoryUsage !== undefined
        ? Number(systemHealthData.memoryUsage)
        : 0
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // ===================== TEMPERATURE =====================
        // ===================== TEMPERATURE =====================
        HudPanel {
            borderColor: "#ffad33"
            width: 280
            Layout.fillHeight: true
            Layout.preferredHeight: 1   // 🔥 ratio

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                ColumnLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "TEMPERATURE"
                        color: "white"
                        font.pixelSize: mainWindow.height/45
                        font.bold: true
                    }


                    Text {
                        text: root.temperature + "°C"
                        color: "#ffad33"
                        font.pixelSize: Math.max(18, 30 * root.scale)
                        font.bold: true
                    }

                    Rectangle {
                        width: 180
                        height: mainWindow.height/70
                        color: "#ffad33"
                        radius: 2
                    }

                    Rectangle {
                        width: 130
                        height: 3
                        color: "#ffad33"
                        opacity: 0.4
                        radius: 2
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // ===================== SENSOR =====================
                HudPanel {
                    id : sensor
                    borderColor: "#33ccff"
                    height: 200
                    width: 280
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // LEFT CIRCLE (100% GAUGE)
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            width: 100
                            height: 100

                            // Double-ring effect seen in reference UI
                            Shape {
                                id:arc_sensor
                                height: sensor.height/10
                                width: sensor.width/100
                                ShapePath {
                                    strokeColor: "#4dff4d"
                                    strokeWidth: 9 // Thicker main ring
                                    fillColor: "transparent"
                                    capStyle: ShapePath.FlatCap
                                    PathAngleArc {
                                        centerX: 65; centerY: 50; radiusX: 45; radiusY: 45
                                        startAngle: 0; sweepAngle: 360
                                    }
                                }
                                // Subtle inner decorative ring
                                ShapePath {
                                    strokeColor: "#4dff4d"
                                    strokeWidth: 2
                                    fillColor: "transparent"
                                    PathAngleArc {
                                        centerX: 65; centerY: 50; radiusX: 35; radiusY: 35
                                        startAngle: 0; sweepAngle: 360
                                    }
                                }
                            }

                            Text {
                                text: battery_value + "%"
                                color: "#4dff4d"
                                font.pixelSize: 15
                                font.bold: true

                                x: arc_sensor.width / 2 + 46
                                y: arc_sensor.height / 2 + 30


                                transformOrigin: Item.Center
                            }
                        }

                        Item { Layout.fillWidth: true } // Spacer to push gauges to edges

                        // RIGHT GAUGE (28 ARC)
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: -30

                            // The Arc with the specific bottom opening
                            Rectangle{
                                width: 150
                                height: 150
                                color: "transparent"
                            }

                            // Layered blue progress bars
                            Column {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 3
                                Rectangle {
                                    width: 110
                                    height: 3
                                    color: "#33ccff"
                                    radius: 1
                                }
                                Rectangle {
                                    width: 75
                                    height: 1
                                    color: "#33ccff"
                                    opacity: 0.4
                                    radius: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
                // ===================== HEALTH =====================
                HudPanel {
                    borderColor: "#4dff4d"
                    width: 280
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1.5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 25 * scale
                        spacing: 12 * scale

                        Text {
                            text: "SYSTEM HEALTH"
                            color: "white"
                            font.pixelSize: 22 * scale
                            font.bold: true
                        }

                        HealthLine { label: "STABLE" }
                        HealthLine { label: "CPU " + (systemHealthData.cpuUsage !== undefined ? systemHealthData.cpuUsage : 0) + "%" }
                        HealthLine { label: "MEMORY " + root.memoryUsage + "%" }
                        HealthLine { label: "NETWORK " + (systemHealthData.network !== undefined ? systemHealthData.network : "--") }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 20 * scale

                        width: 45 * scale
                        height: 22 * scale
                        color: "transparent"
                        border.color: "#4dff4d"
                        border.width: 2 * scale
                        radius: 3 * scale

                        Rectangle {
                            x: 4 * scale
                            y: 4 * scale
                            width: 25 * scale
                            height: 14 * scale
                            color: "#4dff4d"
                        }
                    }
                }
            }

            // ===================== COMPONENTS =====================

            component HudPanel : Rectangle {
                property color borderColor: "white"

                color: "#32383f"
                border.color: borderColor
                border.width: 2 * root.scale
                radius: 15 * root.scale

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: borderColor
                    shadowBlur: 0.4
                }
            }

            component ArcGauge : Item {
                property real size: 100

                width: size
                height: size

                Shape {
                    anchors.fill: parent

                    ShapePath {
                        strokeColor: "#33ccff"
                        strokeWidth: 5 * root.scale
                        fillColor: "transparent"

                        PathAngleArc {
                            centerX: width / 2
                            centerY: height / 2
                            radiusX: width / 2 - 10 * root.scale
                            radiusY: height / 2 - 10 * root.scale
                            startAngle: 140
                            sweepAngle: 260
                        }
                    }
                }
            }

            component HealthLine : RowLayout {
                property string label: ""
                spacing: 10 * root.scale

                Text {
                    text: "✓"
                    color: "#4dff4d"
                    font.pixelSize: 18 * root.scale
                    font.bold: true
                }

                Text {
                    text: label
                    color: "#4dff4d"
                    font.pixelSize: 16 * root.scale
                    Layout.fillWidth: true
                }
            }

}
