import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 60
    color: "#1e293b"   // نفس لون الشريط تقريبًا
    property string missionTime: "00:16:37"
    property int latency: 12
    property int signalStrength: 3   // 0 → 4
    property real baseSpacing: (parent ? parent.width : 1400) * 0.015
    property real smallSpacing: baseSpacing
    property int largeSpacing: baseSpacing * 1.5
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#0a0f1f" }
            GradientStop { position: 1; color: "#05070d" }
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: (parent ? parent.width : 1400) * 0.02
        anchors.rightMargin: (parent ? parent.width : 1400) * 0.02
        spacing: baseSpacing

        // 🔹 LEFT DOTS
        Row {
            spacing: smallSpacing
            Repeater {
                model: 5
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: "#64748b"
                }
            }
        }

        // 🔹 TITLE
        Text {
            text: "TERMAND CARD"
            color: "#e2e8f0"
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        // 🔹 SIGNAL + WIFI + LATENCY
        Row {
            spacing: baseSpacing * 2

            Text { text: "📶"; font.pixelSize: 14 }
            Text { text: "📡"; font.pixelSize: 14 }

            Text {
                text: latency + " ms"
                color: "#cbd5f5"
                font.pixelSize: 13
            }
        }

        // 🔹 CLOCK + TIME
        Row {
            spacing: smallSpacing

            Rectangle {
                id: liveDot
                width: 7
                height: 7
                radius: 4
                color: "#22c55e"

                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite

                    PropertyAnimation { target: liveDot; property: "opacity"; from: 1; to: 0.3; duration: 800 }
                    PropertyAnimation { target: liveDot; property: "opacity"; from: 0.3; to: 1; duration: 800 }
                }
            }

            Text { text: "🕒"; font.pixelSize: 14 }

            Text {
                text: "MISSION TIME: " + missionTime
                color: "#e2e8f0"
                font.pixelSize: 13
            }
        }

        Item { Layout.fillWidth: true }

        // 🔹 RIGHT SIDE
        RowLayout {
            spacing: baseSpacing * 0.6

            Rectangle {
                width: 34
                height: 34
                radius: 10
                color: "#0f172a"
                border.color: "#1e293b"

                Text {
                    anchors.centerIn: parent
                    text: "AI"
                    color: "#38bdf8"
                    font.bold: true
                }
            }

            Column {
                spacing: 2

                Text {
                    text: "SYSTEM"
                    color: "#64748b"
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                }

                Text {
                    text: "ROBOT COMMAND CENTER"
                    color: "#e2e8f0"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2

        gradient: Gradient {
            GradientStop { position: 0; color: "#0ea5e9" }
            GradientStop { position: 0.5; color: "#22c55e" }
            GradientStop { position: 1; color: "transparent" }
        }

        opacity: 0.5
    }

}
