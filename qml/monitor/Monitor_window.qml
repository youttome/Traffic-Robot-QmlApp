import QtQuick
import QtQuick.Layouts

Rectangle {
    id: monitor

    /* =========================
       ROOT PROPERTIES
    ========================= */
    property int monitorWidth: 400
    property int monitorHeight: 300
    property color backgroundColor: "#05070d"

    /* Layout */
    property int marginSize: 10
    property int spacingSize: 10
    property int innerSpacing: 8
    property int cornerRadius: 6

    /* Bars Height */
    property int topBarHeight: 50
    property int bottomBarHeight: 50

    /* Ratios */
    property int leftPanelRatio: 5
    property int rightPanelRatio: 3

    /* Colors */
    property color topBarColor: "transparent"
    property color bottomBarColor: "#05080b"
    property color leftPanelColor: "#0b1017"
    property color rightPanelColor: "#0b1017"
    property color bottomLeftColor: "#0b1017"
    property color bottomRightColor: "#0b1017"

    width: monitorWidth
    height: monitorHeight
    color: backgroundColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: marginSize
        spacing: spacingSize

        /* =========================
           TOP BAR
        ========================= */
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: topBarHeight
            color: topBarColor
            radius: cornerRadius

            HUDStatusBar {
                anchors.fill: parent
            }
        }

        /* =========================
           MIDDLE SECTION
        ========================= */
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: innerSpacing

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: leftPanelRatio

                color: leftPanelColor
                border.color: "#16212b"
                border.width: 1
                radius: cornerRadius

                CameraNetwork {
                    anchors.fill: parent
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: rightPanelRatio

                color: rightPanelColor
                border.color: "#16212b"
                border.width: 1
                radius: cornerRadius

                TrafficPanel {
                    anchors.fill: parent
                }
            }
        }

        /* =========================
           BOTTOM BAR
        ========================= */
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: bottomBarHeight

            color: bottomBarColor
            border.color: "#16212b"
            border.width: 1
            radius: cornerRadius

            RowLayout {
                anchors.fill: parent
                anchors.margins: marginSize
                spacing: innerSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: leftPanelRatio

                    color: bottomLeftColor
                    border.color: "#16212b"
                    border.width: 1
                    radius: cornerRadius

                    BottomBar {
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: rightPanelRatio

                    color: bottomRightColor
                    border.color: "#16212b"
                    border.width: 1
                    radius: cornerRadius

                    BottomBarRight {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
