import QtQuick
import QtQuick.Layouts

Rectangle {
    id: cardRoot

    property string title: "UNIT-01"
    property string imageSource: ""
    property string topicName: ""
    property string signalText: "WAITING"
    property string subStatus: "Operational"
    property string metaText: ""
    property color accentColor: "#5fc9d9"
    property color signalColor: signalText === "LIVE" ? "#2ecc71" : "#f39c12"

    color: "#091019"
    border.color: "#1f2d35"
    border.width: 1
    radius: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: cardRoot.title
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    font.capitalization: Font.AllUppercase
                }

                Text {
                    text: cardRoot.topicName
                    color: "#7a8d9e"
                    font.pixelSize: 10
                    font.family: "Monospace"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                radius: 8
                color: "#0f1822"
                border.color: cardRoot.signalColor
                border.width: 1
                Layout.preferredWidth: 88
                Layout.preferredHeight: 28

                Text {
                    anchors.centerIn: parent
                    text: cardRoot.signalText
                    color: cardRoot.signalColor
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#05080a"
            border.color: "#16212b"
            border.width: 1
            clip: true

            Image {
                id: videoFrame
                anchors.fill: parent
                source: cardRoot.imageSource
                fillMode: Image.PreserveAspectCrop
                cache: false
                smooth: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.14
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = cardRoot.accentColor;
                    ctx.lineWidth = 2;
                    var len = 16;

                    ctx.beginPath();
                    ctx.moveTo(8, 8 + len); ctx.lineTo(8, 8); ctx.lineTo(8 + len, 8);
                    ctx.moveTo(width - 8 - len, 8); ctx.lineTo(width - 8, 8); ctx.lineTo(width - 8, 8 + len);
                    ctx.moveTo(8, height - 8 - len); ctx.lineTo(8, height - 8); ctx.lineTo(8 + len, height - 8);
                    ctx.moveTo(width - 8 - len, height - 8); ctx.lineTo(width - 8, height - 8); ctx.lineTo(width - 8, height - 8 - len);
                    ctx.stroke();
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 10
                radius: 6
                color: "#99000000"
                border.color: "#27404f"
                border.width: 1
                width: 170
                height: 52

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: cardRoot.subStatus
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: cardRoot.metaText
                        color: "#7fd9e8"
                        font.pixelSize: 10
                        visible: text.length > 0
                    }
                }
            }
        }
    }
}
