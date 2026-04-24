// Example application showing the usage of
// Qt Quick Effect Maker effects in Qt 6.8


pragma ComponentBehavior: Bound

// Example application showing page transition with StackView
// Qt Quick + custom pages

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "monitor"

Window {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    title: "TRAFFIC ROBOT MONITORING"
    visibility: Qt.platform.os == "android" ? Window.FullScreen : Window.Windowed

    readonly property real px: Math.min(width / 960, height / 540)
    property real performance_value : systemMonitor.performanceValue
    property int  battery_value: systemMonitor.batteryValue
    Material.accent: "#FFFFFF"
    FontLoader {
        id: customFont
        source: "monofonto.otf"
    }
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: page1

        pushEnter: Transition {
            NumberAnimation {
                property: "x"
                from: stackView.width
                to: 0
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        pushExit: Transition {
            NumberAnimation {
                property: "x"
                from: 0
                to: -stackView.width / 3
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        popEnter: Transition {
            NumberAnimation {
                property: "x"
                from: -stackView.width / 3
                to: 0
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        popExit: Transition {
            NumberAnimation {
                property: "x"
                from: 0
                to: stackView.width
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component {
        id: page1

        Page {
            Rectangle {
                anchors.fill: parent
                id: mainWindow
                property real px: Math.min(width / 960, height / 540)
                property real performance_value : systemMonitor.performanceValue
                property int  battery_value: systemMonitor.batteryValue
                Material.accent: "#FFFFFF"
                visible: true
                FontLoader {
                    id: customFont
                    source: "monofonto.otf"
                }
                Main_window{}
            }
        }
    }

    Component {
        id: page2

        Page {
            Rectangle {
                anchors.fill: parent
                color: "#101010"

                Monitor_window {
                    anchors.fill: parent
                }


            }
        }
    }
}

/*
Window {
    id: mainWindow

    readonly property real px: Math.min(width / 960, height / 540)
    property real performance_value : systemMonitor.performanceValue
    property int  battery_value: systemMonitor.batteryValue
    Material.accent: "#FFFFFF"
    width: 1920 / 2
    height: 1080 / 2
    visible: true
    visibility: Qt.platform.os == "android" ? Window.FullScreen : Window.Windowed
    color: "#202020"
    title: qsTr("CircleBarsUI")
    FontLoader {
        id: customFont
        source: "monofonto.otf"
    }
    Main_window{}

}
