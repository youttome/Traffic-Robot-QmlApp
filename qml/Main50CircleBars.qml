import QtQuick
import QtQuick.Effects

Window {
    id: mainWindow

    readonly property real px: Math.min(width / 960, height / 540)
    readonly property bool landscape: width > height
    property int barColumns: landscape ? 10 : 5
    property int barRows: landscape ? 5 : 10
    property real barWidth: (width / barColumns) - barsGrid.columnSpacing
    property real barHeight: ((height - logoImage.height - 20) / barRows) - barsGrid.rowSpacing

    width: 1920 / 2
    height: 1080 / 2
    visible: true
    //visibility: Window.FullScreen
    title: qsTr("50 CircleBars")
    color: "#202020"

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "background.jpg"
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: -0.4
            contrast: -0.9
            saturation: -1.0
        }
    }

    Image {
        id: logoImage
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        source: "Qt-Development-white.png"
        width: parent.width * 0.3
        height: width * 0.2
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    FontLoader {
        id: font1
        source: "monofonto.otf"
    }

    FrameAnimation {
        id: frameAnimation
        running: true
    }

    Text {
        id: fpsText
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        color: "#ffffff"
        font.pixelSize: logoImage.height * 0.4
        font.family: font1.font.family
        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: {
                fpsText.text = Math.round(1.0 / frameAnimation.smoothFrameTime) + " FPS"
            }
        }
    }

    Grid {
        id: barsGrid
        anchors.top: logoImage.bottom
        anchors.topMargin: 10
        x: columnSpacing / 2
        columns: barColumns
        rowSpacing: 20 * px
        columnSpacing: 20 * px
        Repeater {
            model: barColumns * barRows
            Item {
                width: mainWindow.barWidth
                height: mainWindow.barHeight
                CircleBar {
                    id: circleBar
                    readonly property real animationPhase: Math.random() * Math.PI * 2
                    // Extra needed for glow margins and still reach 360 degrees
                    readonly property real extraSpanAngle: 1.2
                    anchors.centerIn: parent
                    width: parent.width
                    height: width
                    value: 0.505 + 0.5 * Math.sin(frameAnimation.elapsedTime + animationPhase)
                    startAngle: (Math.PI * 1.5) - (spanAngle * 0.5)
                    spanAngle: 1.4 * Math.PI + 0.6 * Math.random() * Math.PI + extraSpanAngle
                    barHeight: 0.2 + 0.8 * Math.random()
                    barsAmount: 6 + Math.random() * 40
                    barsDistribution: 0.2 + 0.6 * Math.random()
                    barsColor: Qt.rgba(Math.random(),
                                            Math.random(),
                                            Math.random(),
                                            1.0)
                    highlightColor: barsColor
                    glowBloom: 0.5 + 1.5 * Math.random()
                    barsSmoothness: 0.5 + 4.0 * Math.random()
                    Text {
                        anchors.centerIn: parent
                        text: Math.round(circleBar.value * 100) + "%"
                        color: "#ffffff"
                        font.pixelSize: circleBar.height * 0.35 -  circleBar.height * 0.2 * circleBar.barHeight
                        font.family: font1.font.family
                        opacity: 0.3 + 0.6 * circleBar.value
                        scale: 0.7 + 0.3 * circleBar.value
                    }
                }
            }
        }
    }
}
