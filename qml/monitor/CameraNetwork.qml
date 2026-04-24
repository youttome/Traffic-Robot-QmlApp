import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    color: "#0d1117"
    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var networkUi: uiData.cameraNetwork || ({})
    readonly property var cardUi: uiData.cameraCards || ({})
    readonly property var robotUi: cardUi.robot || ({})
    readonly property var streetAUi: cardUi.streetA || ({})
    readonly property var streetBUi: cardUi.streetB || ({})
    readonly property int liveCount: (rosStreams.robotOnline ? 1 : 0)
        + (rosStreams.streetAOnline ? 1 : 0)
        + (rosStreams.streetBOnline ? 1 : 0)
    property int frameSeed: 0

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: root.frameSeed = Date.now()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "#161b22"
            border.color: "#30363d"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: networkUi.title || "ROS CAMERA NETWORK + STREET AI"
                        color: "#5fc9d9"
                        font.pixelSize: 19
                        font.letterSpacing: 1.3
                        font.bold: true
                    }

                    Text {
                        text: networkUi.subtitle || "Topics: live ROS camera feeds and AI street monitor"
                        color: "#8ba0b3"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }

                    Text {
                        text: rosStreams.robotTopic + " | " + rosStreams.streetATopic + " | " + rosStreams.streetBTopic
                        color: "#5a7288"
                        font.pixelSize: 10
                        font.family: "Monospace"
                        elide: Text.ElideMiddle
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 92
                    Layout.preferredHeight: 36
                    radius: 10
                    color: "#0f1822"
                    border.color: root.liveCount > 0 ? "#2ecc71" : "#f39c12"
                    border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.liveCount + "/3 " + (networkUi.liveSuffix || "LIVE")
                    color: root.liveCount > 0 ? "#2ecc71" : "#f39c12"
                    font.pixelSize: 11
                    font.bold: true
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 15

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rows: 2
                columnSpacing: 14
                rowSpacing: 14

                CameraCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: robotUi.title || "Robot FPV"
                    topicName: rosStreams.robotTopic
                    imageSource: "image://roscam/robot?" + root.frameSeed
                    signalText: rosStreams.robotSignal
                    subStatus: rosStreams.robotOnline
                        ? (robotUi.onlineText || "ROS image stream online")
                        : (robotUi.offlineText || "Waiting for /cam_robot")
                    metaText: rosStreams.robotFps + " FPS"
                }

                MapIntelCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                CameraCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: streetAUi.title || "Street A"
                    topicName: rosStreams.streetATopic
                    imageSource: "image://roscam/streetA?" + root.frameSeed
                    signalText: rosStreams.streetASignal
                    subStatus: rosStreams.streetAOnline
                        ? (streetAUi.onlineText || "AI visibility normal")
                        : (streetAUi.offlineText || "Waiting for /cam_A")
                    metaText: rosStreams.streetAFps + " FPS"
                }

                CameraCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: streetBUi.title || "Street B"
                    topicName: rosStreams.streetBTopic
                    imageSource: "image://roscam/streetB?" + root.frameSeed
                    signalText: rosStreams.streetBSignal
                    subStatus: rosStreams.streetBOnline
                        ? (streetBUi.onlineText || "AI tracking active")
                        : (streetBUi.offlineText || "Waiting for /cma_B")
                    metaText: rosStreams.streetBFps + " FPS"
                }
            }

            StreetAIPanel {
                Layout.preferredWidth: 310
                Layout.fillHeight: true
            }
        }
    }
}
