import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: "#0a0f14" // Deep dark background

    property color accentColor: "#5fc9d9"
    property color bgColor: "#1a252b"
    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var hudUi: uiData.hud || ({})
    readonly property var systemHealthData: dataManager.systemHealth || ({})
    readonly property var telemetryData: dataManager.robotTelemetry || ({})

    // Real-time clock
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss");
            dateText.text = new Date().toLocaleDateString(Qt.locale(), "yyyy.MM.dd");
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // --- SYSTEM HEALTH SECTION ---
        RowLayout {
            Layout.fillWidth: true

            // Gear Icon with Circular border
            Rectangle {
                width: 50; height: 50
                color: "transparent"
                border.color: root.accentColor
                border.width: 1
                radius: 4
                Text {
                    anchors.centerIn: parent
                    text: "⚙" // Use an Icon font or Image here
                    font.pixelSize: 24
                    color: root.accentColor
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: hudUi.healthTitle || "SYSTEM HEALTH"
                    font.pixelSize: 12
                    font.letterSpacing: 1
                    color: "#a0aab0"
                }

                Text {
                    text: hudUi.healthSubtitle || "Realtime diagnostics"
                    font.pixelSize: 9
                    color: "#5f7d92"
                }

                // Health Bar
                Rectangle {
                    width: 150; height: 4
                    color: root.bgColor
                    Rectangle {
                        width: parent.width * ((root.systemHealthData.systemHealth !== undefined ? root.systemHealthData.systemHealth : 75) / 100)
                        height: parent.height
                        color: root.accentColor
                        Behavior on width { NumberAnimation { duration: 500 } }
                    }
                }

                // Mini Histogram
                Row {
                    spacing: 2
                    Repeater {
                        model: 20
                        Rectangle {
                            width: 3
                            height: Math.random() * 15 + 2
                            color: index < (root.systemHealthData.systemHealth !== undefined ? root.systemHealthData.systemHealth : 75) / 5 ? root.accentColor : "#33444d"
                            anchors.bottom: parent.bottom
                        }
                    }
                }
            }
        }

        // --- NETWORK SECTION ---
        RowLayout {
            spacing: 10
            Text { text: "📶"; color: root.accentColor; font.pixelSize: 20 }
            ColumnLayout {
                Text { text: hudUi.networkLabel || "NETWORK"; font.pixelSize: 10; color: "#a0aab0" }
                Text { 
                    text: root.systemHealthData.network !== undefined ? root.systemHealthData.network : "5G"
                    font.pixelSize: 18; color: "white"; font.bold: true 
                }
            }
        }

        // --- BATTERY SECTION ---
        RowLayout {
            spacing: 10
            Rectangle {
                width: 45; height: 22
                color: "transparent"
                border.color: root.accentColor
                border.width: 1
                radius: 3
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 3
                    height: parent.height - 6
                    width: Math.max(0, (parent.width - 6) * ((root.systemHealthData.battery !== undefined ? root.systemHealthData.battery : 85) / 100))
                    color: {
                        var batteryLevel = root.systemHealthData.battery !== undefined ? root.systemHealthData.battery : 85;
                        if (batteryLevel > 70) return "#2ecc71"; // Green
                        if (batteryLevel > 30) return "#f1c40f"; // Yellow
                        return "#e74c3c"; // Red
                    }
                    radius: 2
                    Behavior on width { NumberAnimation { duration: 500 } }
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
            ColumnLayout {
                Text { text: hudUi.batteryLabel || "BATTERY"; font.pixelSize: 10; color: "#a0aab0" }
                Text { 
                    text: (root.systemHealthData.battery !== undefined ? root.systemHealthData.battery : 85) + "%"
                    font.pixelSize: 18; color: "white"; font.bold: true 
                }
            }
        }

        // --- DATE & TIME SECTION ---
        RowLayout {
            spacing: 20

            // Date
            RowLayout {
                Text { text: "📅"; color: root.accentColor; font.pixelSize: 20 }
                ColumnLayout {
                    Text { text: hudUi.dateLabel || "DATE"; font.pixelSize: 10; color: "#a0aab0" }
                    Text { 
                        id: dateText
                        text: new Date().toLocaleDateString(Qt.locale(), "yyyy.MM.dd")
                        font.pixelSize: 16; color: "white" 
                    }
                }
            }

            // Separator
            Rectangle { width: 1; height: 30; color: "#33444d" }

            // Time
            ColumnLayout {
                Text { text: hudUi.timeLabel || "TIME"; font.pixelSize: 10; color: "#a0aab0" }
                Text { 
                    id: timeText
                    text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss")
                    font.pixelSize: 20; color: "white"; font.family: "Monospace" 
                }
            }

            Rectangle { width: 1; height: 30; color: "#33444d" }

            ColumnLayout {
                Text { text: "MISSION"; font.pixelSize: 10; color: "#a0aab0" }
                Text {
                    text: telemetryData.missionTime !== undefined ? telemetryData.missionTime : "00:00:00"
                    font.pixelSize: 16
                    color: "white"
                    font.family: "Monospace"
                }
            }
        }
    }

    // Outer "Techno" Border Frame
    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#33444d";
            ctx.lineWidth = 1;
            ctx.beginPath();
            // Drawing the notched corners
            ctx.moveTo(0, 20);
            ctx.lineTo(20, 0);
            ctx.lineTo(width - 20, 0);
            ctx.lineTo(width, 20);
            ctx.lineTo(width, height - 20);
            ctx.lineTo(width - 20, height);
            ctx.lineTo(20, height);
            ctx.lineTo(0, height - 20);
            ctx.closePath();
            ctx.stroke();
        }
    }
}
