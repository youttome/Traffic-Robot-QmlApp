import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: "#0a0f14"
    border.color: "#30363d"
    border.width: 1
    radius: 6

    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var bottomStatusUi: uiData.bottomStatus || ({})
    readonly property int liveCount: (rosStreams.robotOnline ? 1 : 0)
        + (rosStreams.streetAOnline ? 1 : 0)
        + (rosStreams.streetBOnline ? 1 : 0)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 18

        ColumnLayout {
            spacing: 0

            Text {
                text: bottomStatusUi.networkTitle || "ROS NETWORK"
                font.pixelSize: 10
                color: "#a0aab0"
                font.bold: true
            }

            Text {
                text: liveCount + "/3 " + (bottomStatusUi.streamSuffix || "STREAMS ONLINE")
                font.pixelSize: 16
                color: "white"
                font.family: "Monospace"
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: "#23313d"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: (bottomStatusUi.aiTopicLabel || "AI TOPIC") + ": " + rosStreams.aiTopic
                color: "#7fd9e8"
                font.pixelSize: 10
                font.family: "Monospace"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }

            Text {
                text: rosStreams.aiSummary
                color: "white"
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
