import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: bottomBar
    width: parent.width
    height: 70
    color: "#0a0f14"
    anchors.bottom: parent.bottom

    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var bottomUi: uiData.bottomBar || ({})
    readonly property color accentCyan: "#5fc9d9"
    readonly property color dangerRed: "#ff4d4d"

    // Top border line with a subtle glow
    Rectangle {
        width: parent.width
        height: 1
        anchors.top: parent.top
        color: accentCyan
        opacity: 0.5
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20

        // --- HOME BUTTON ---
        NavButton {
            id: homeBtn
            text: bottomUi.homeLabel || "HOME"
            icon: "🏠"
            Layout.preferredWidth: 120
            onClicked: console.log("Navigating Home...")
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                    onClicked: stackView.pop()

            }
        }

        // Spacer to push emergency to the center/right
        Item { Layout.fillWidth: true }

        // --- EMERGENCY BUTTON ---
        NavButton {
            id: emergencyBtn
            text: bottomUi.emergencyLabel || "EMERGENCY"
            icon: "⚠️"
            baseColor: "#2a0000"
            borderColor: dangerRed
            textColor: dangerRed
            glowColor: Qt.rgba(1, 0, 0, 0.3)
            Layout.preferredWidth: 180
            onClicked: console.log("EMERGENCY TRIGGERED")

            // Optional pulse animation for emergency
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.6; duration: 800 }
                NumberAnimation { from: 0.6; to: 1.0; duration: 800 }
            }
        }

        Item { Layout.fillWidth: true }

        // --- SETTINGS/OTHER ---
        NavButton {
            text: bottomUi.systemLabel || "SYSTEM"
            icon: "⚙️"
            Layout.preferredWidth: 120
        }
    }

    // --- REUSABLE BUTTON COMPONENT ---
    component NavButton : Item {
        id: control
        property string text: "BUTTON"
        property string icon: ""
        property color baseColor: "#161b22"
        property color borderColor: accentCyan
        property color textColor: "white"
        property color glowColor: Qt.rgba(0.37, 0.79, 0.85, 0.2)
        signal clicked()

        height: 45

        Rectangle {
            id: bg
            anchors.fill: parent
            color: mouseArea.containsPress ? Qt.lighter(baseColor, 1.2) : baseColor
            border.color: borderColor
            border.width: 1
            radius: 2

            // Notched corner effect (Canvas)
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = borderColor;
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(0, 10);
                    ctx.lineTo(10, 0);
                    ctx.stroke();
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 8
                Text { text: icon; font.pixelSize: 18; verticalAlignment: Text.AlignVCenter }
                Text {
                    text: control.text
                    color: control.textColor
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: control.clicked()
        }
    }
}
