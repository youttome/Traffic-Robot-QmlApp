import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle{
    anchors.fill: parent
    visible: true
    Rectangle {
        width: parent.width
        height: 80
        color: "#0a111a" // Dark space background

        RowLayout {
            anchors.fill: parent
            spacing: 25

            // --- SYSTEM HEALTH SECTION ---

            Rectangle {
                width: 200; height: 80
                color: "#1a2a3a"
                opacity: 0.8
                radius: 10
                border.color: "#334455"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Text {
                        text: "✔"
                        color: "#4CAF50"
                        font.pixelSize: 24
                    }
                    Column {
                        Text { text: "SYSTEM HEALTH"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "All Systems Online"; color: "#aaaaaa"; font.pixelSize: 12 }
                    }
                }
            }

            // --- ACTION BUTTONS SECTION ---
            Rectangle {
                Layout.preferredWidth: 400; Layout.preferredHeight: 80
                color: "transparent"
                border.color: "#334455"
                radius: 10

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    // Deploy Button
                    Button {
                        contentItem: Text {
                            text: "DEPLOY ROBOT"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 160; implicitHeight: 45
                            color: "#3498db"
                            radius: 22
                            border.width: 2
                            border.color: "#5dade2"
                        }
                    }

                    // Emergency Stop Button
                    Button {
                        contentItem: Text {
                            text: "EMERGENCY STOP"
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            implicitWidth: 160; implicitHeight: 45
                            color: "#e74c3c"
                            radius: 22
                            border.width: 2
                            border.color: "#ec7063"
                        }
                    }
                }
            }

            // --- JOYSTICK / STATUS CIRCLE ---
            Item {
                width: 80; height: 80

                // The blue glowing rings
                Rectangle {
                    anchors.fill: parent
                    radius: width/2
                    color: "transparent"
                    border.color: "#00d2ff"
                    border.width: 2
                    opacity: 0.6
                }

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: "white"
                    font.pixelSize: 30
                }
            }

            // --- MANUAL CONTROL SECTION ---
            Rectangle {
                width: 150; height: 80
                color: "transparent"
                border.color: "#334455"
                radius: 10

                Text {
                    anchors.centerIn: parent
                    text: "MANUAL\nCONTROL"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: stackView.push(page2)
                }
            }
        }
    }

}
