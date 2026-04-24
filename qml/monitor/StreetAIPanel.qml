import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property color accentColor: "#5fc9d9"
    property color warningColor: "#f39c12"
    property color liveColor: "#2ecc71"
    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var panelUi: uiData.aiPanel || ({})
    readonly property int activeEvents: dataManager.trafficViolations ? dataManager.trafficViolations.length : 0
    readonly property string aiSignal: rosStreams.aiOnline ? "LIVE" : "WAITING"
    readonly property string summaryText: (rosStreams.aiSummary && rosStreams.aiSummary.length > 0)
        ? rosStreams.aiSummary
        : (panelUi.fallbackSummary || "Waiting for AI summary on /street_ai_monitor")

    color: "#091019"
    border.color: "#1f2d35"
    border.width: 1
    radius: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: panelUi.title || "AI STREET MONITOR"
                    color: "white"
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    text: rosStreams.aiTopic
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
                border.color: rosStreams.aiOnline ? root.liveColor : root.warningColor
                border.width: 1
                Layout.preferredWidth: 90
                Layout.preferredHeight: 28

                Text {
                    anchors.centerIn: parent
                    text: root.aiSignal
                    color: rosStreams.aiOnline ? root.liveColor : root.warningColor
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            radius: 10
            color: "#05080a"
            border.color: "#16212b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: panelUi.summaryLabel || "SUMMARY"
                    color: root.accentColor
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: root.summaryText
                    color: "white"
                    font.pixelSize: 13
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 1
            rowSpacing: 8

            StreamLine {
                label: panelUi.robotLabel || "ROBOT"
                signalText: rosStreams.robotSignal
                online: rosStreams.robotOnline
                fpsText: rosStreams.robotFps + " FPS"
            }

            StreamLine {
                label: panelUi.streetALabel || "STREET A"
                signalText: rosStreams.streetASignal
                online: rosStreams.streetAOnline
                fpsText: rosStreams.streetAFps + " FPS"
            }

            StreamLine {
                label: panelUi.streetBLabel || "STREET B"
                signalText: rosStreams.streetBSignal
                online: rosStreams.streetBOnline
                fpsText: rosStreams.streetBFps + " FPS"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "#05080a"
            border.color: "#16212b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: panelUi.queueTitle || "AI INCIDENT QUEUE"
                    color: root.accentColor
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    text: root.activeEvents + " " + (panelUi.queueSuffix || "traffic events synced from live datastore")
                    color: "white"
                    font.pixelSize: 13
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: root.activeEvents === 0
                    visible: root.activeEvents === 0
                    radius: 8
                    color: "#0d141d"
                    border.color: "#21303c"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: panelUi.emptyQueueTitle || "No incidents"
                            color: "white"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: panelUi.emptyQueueSubtitle || "Traffic events will appear here as soon as the database updates."
                            color: "#7a8d9e"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            width: 220
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Repeater {
                    model: Math.min(3, root.activeEvents)

                    delegate: Rectangle {
                        readonly property var eventData: (dataManager.trafficViolations && dataManager.trafficViolations[index])
                            ? dataManager.trafficViolations[index]
                            : ({})
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 8
                        color: "#0d141d"
                        border.color: "#21303c"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: eventData.color || root.accentColor
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: eventData.violation || "Unnamed event"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text {
                                    text: (eventData.plate || "--") + "  •  " + (eventData.time || "--:--")
                                    color: "#7a8d9e"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component StreamLine : Rectangle {
        property string label: ""
        property string signalText: ""
        property bool online: false
        property string fpsText: ""

        Layout.fillWidth: true
        implicitHeight: 40
        radius: 8
        color: "#0d141d"
        border.color: "#21303c"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: label
                color: "white"
                font.pixelSize: 11
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: fpsText
                color: "#7fd9e8"
                font.pixelSize: 10
            }

            Text {
                text: signalText
                color: online ? root.liveColor : root.warningColor
                font.pixelSize: 10
                font.bold: true
            }
        }
    }
}
