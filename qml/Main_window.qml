import QtQuick
import QtQuick.Layouts

Rectangle {
    id: main
    anchors.fill: parent
    color: "black"

    ColumnLayout {
        anchors.fill: parent

        // 🔵 Top
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            Top_Bar {
                anchors.fill: parent
                missionTime: topBarData.missionTime
                latency: topBarData.latency
                signalStrength: topBarData.signalStrength
            }
        }

        // 🟢 Middle
        Rectangle {
            color: "#0a111a"
            Layout.fillWidth: true
            Layout.fillHeight: true   // ✔ ياخد الباقي

            RowLayout {
                anchors.fill: parent
                spacing: 5

                Rectangle {
                    color: "transparent"
                    width: 300
                    Layout.fillHeight: true
                    Left_Bar{
                    id:left
                    anchors.fill:parent
                    }
                }
                Rectangle {
                    color: "transparent"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    MapView{
                        anchors.fill: parent
                    }
                }
            }
        }

        // 🔵 Bottom
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            Bottom_Bar{}
        }
    }
}
