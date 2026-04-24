import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property int panelWidth: 450
    property int panelHeight: 800

    property color bgColor: "#101820"
    property color borderColor: "#2c3e50"
    property color accentBlue: "#5fc9d9"
    property color textMain: "#ffffff"
    property color textDim: "#8b949e"
    property bool syncingSignal: false
    property string activeDir: "A"
    property bool aiMode: true
    property bool manualMode: false
    property int yellowDuration: 3

    readonly property var uiData: dataManager.monitorUi || ({})
    readonly property var panelUi: uiData.trafficPanel || ({})
    readonly property var signalData: dataManager.signalControl || ({})
    readonly property var violations: dataManager.trafficViolations || []
    readonly property var vehicles: dataManager.priorityVehicles || []
    readonly property var demoViolations: panelUi.demoViolations || []

    width: panelWidth
    height: panelHeight
    color: bgColor

    function syncSignalFromDatabase() {
        syncingSignal = true
        activeDir = signalData.activeDir !== undefined ? signalData.activeDir : "A"
        aiMode = signalData.aiMode !== undefined ? signalData.aiMode : true
        manualMode = signalData.manualMode !== undefined ? signalData.manualMode : false
        yellowDuration = signalData.yellowDuration !== undefined ? signalData.yellowDuration : 3
        syncingSignal = false
    }

    function persistSignalControl() {
        if (syncingSignal)
            return

        dataManager.patchSignalControl({
            activeDir: activeDir,
            aiMode: aiMode,
            manualMode: manualMode,
            yellowDuration: yellowDuration
        })
    }

    function addDemoViolation() {
        var fallbackPalette = ["#e74c3c", "#d35400", "#f1c40f", "#9b59b6"]
        var fallbackMessages = ["تجاوز السرعة", "تجاوز الإشارة", "سير عكسي", "وقوف مخالف"]
        var nextIndex = violations.length % Math.max(1, demoViolations.length)
        var template = demoViolations.length > 0 ? demoViolations[nextIndex] : ({
            color: fallbackPalette[nextIndex % fallbackPalette.length],
            message: fallbackMessages[nextIndex % fallbackMessages.length]
        })
        dataManager.addTrafficViolation({
            color: template.color,
            plate: "AI-" + String(Date.now()).slice(-4),
            violation: template.message,
            time: Qt.formatTime(new Date(), "hh:mm"),
            timestamp: Math.floor(Date.now() / 1000)
        })
    }

    function updateVehicleChecked(index, checked) {
        var nextVehicles = vehicles.slice()
        var nextVehicle = Object.assign({}, nextVehicles[index])
        nextVehicle.checked = checked
        nextVehicles[index] = nextVehicle
        dataManager.updatePriorityVehicles(nextVehicles)
    }

    Component.onCompleted: syncSignalFromDatabase()

    onActiveDirChanged: persistSignalControl()
    onYellowDurationChanged: persistSignalControl()
    onAiModeChanged: {
        if (syncingSignal)
            return
        if (aiMode && manualMode) {
            syncingSignal = true
            manualMode = false
            syncingSignal = false
        }
        persistSignalControl()
    }
    onManualModeChanged: {
        if (syncingSignal)
            return
        if (manualMode && aiMode) {
            syncingSignal = true
            aiMode = false
            syncingSignal = false
        }
        persistSignalControl()
    }

    Connections {
        target: dataManager

        function onSignalControlChanged() {
            root.syncSignalFromDatabase()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: panelUi.title || "TRAFFIC MANAGEMENT INTERFACE"
            color: accentBlue
            font.pixelSize: 20
            font.letterSpacing: 1.2
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }

        HUDSection {
            title: panelUi.violationsTitle || "TRAFFIC VIOLATION LOG"
            Layout.fillWidth: true
            implicitHeight: 260

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    HeaderText { text: panelUi.colorHeader || "COLOR"; Layout.preferredWidth: 50 }
                    HeaderText { text: panelUi.plateHeader || "LICENSE PLATE"; Layout.preferredWidth: 110 }
                    HeaderText { text: panelUi.violationHeader || "VIOLATION"; Layout.fillWidth: true }
                    HeaderText { text: panelUi.timeHeader || "TIME"; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: violations
                    delegate: RowLayout {
                        Layout.fillWidth: true

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: modelData.color
                            border.color: "white"
                        }

                        Rectangle {
                            Layout.preferredWidth: 95
                            height: 22
                            color: "white"
                            radius: 3

                            Text {
                                anchors.centerIn: parent
                                text: modelData.plate
                                color: "black"
                                font.bold: true
                                font.pixelSize: 12
                            }
                        }

                        BodyText {
                            text: modelData.violation
                            Layout.fillWidth: true
                        }

                        BodyText {
                            text: modelData.time
                            Layout.preferredWidth: 60
                            horizontalAlignment: Text.AlignRight
                            color: textDim
                            font.pixelSize: 11
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: panelUi.addDemoLabel || "ADD DEMO"
                        onClicked: root.addDemoViolation()
                    }

                    Button {
                        text: panelUi.clearLatestLabel || "CLEAR LATEST"
                        enabled: violations.length > 0
                        onClicked: dataManager.removeTrafficViolation(0)
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: violations.length + " records"
                        color: accentBlue
                        font.pixelSize: 11
                        font.italic: true
                    }
                }
            }
        }

        HUDSection {
            title: panelUi.vehiclesTitle || "PRIORITY VEHICLE QUEUE"
            Layout.fillWidth: true
            implicitHeight: 170

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    HeaderText { text: panelUi.setHeader || "SET"; Layout.preferredWidth: 35 }
                    HeaderText { text: panelUi.vehicleHeader || "VEHICLE"; Layout.preferredWidth: 110 }
                    HeaderText { text: panelUi.distanceHeader || "DISTANCE"; Layout.preferredWidth: 80 }
                    HeaderText { text: panelUi.levelHeader || "LVL"; Layout.preferredWidth: 30 }
                    HeaderText { text: panelUi.statusHeader || "STATUS"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: vehicles
                    delegate: RowLayout {
                        Layout.fillWidth: true

                        CheckBox {
                            id: vehicleToggle
                            checked: modelData.checked
                            scale: 0.7
                            Layout.preferredWidth: 35

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                color: "transparent"
                                border.color: accentBlue

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 10
                                    height: 10
                                    color: accentBlue
                                    visible: vehicleToggle.checked
                                }
                            }

                            onToggled: root.updateVehicleChecked(index, checked)
                        }

                        BodyText { text: modelData.type; Layout.preferredWidth: 110 }
                        BodyText { text: modelData.distance; Layout.preferredWidth: 80; color: textDim }
                        BodyText { text: modelData.level; Layout.preferredWidth: 30; color: "#f1c40f"; font.bold: true }
                        BodyText { text: modelData.status; color: modelData.color; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                }
            }
        }

        HUDSection {
            title: panelUi.controlTitle || "INTELLIGENT INTERSECTION CONTROL"
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 25

                ColumnLayout {
                    spacing: 20

                    TrafficLight {
                        label: panelUi.streetALabel || "STREET A"
                        currentState: root.activeDir === "A" ? "green" : (root.activeDir === "YELLOW_A" ? "yellow" : "red")
                    }

                    TrafficLight {
                        label: panelUi.streetBLabel || "STREET B"
                        currentState: root.activeDir === "B" ? "green" : (root.activeDir === "YELLOW_B" ? "yellow" : "red")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#11161c"
                    border.color: "#2c333b"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        Text {
                            text: panelUi.signalModesTitle || "SIGNAL TIMING & MODES"
                            color: "#7ef9ff"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        RowLayout {
                            ControlRow {
                                label: panelUi.aiAutoLabel || "AI AUTO"
                                isSwitchedOn: root.aiMode
                                onToggled: function(s) { root.aiMode = s }
                            }

                            ControlRow {
                                label: panelUi.manualLabel || "MANUAL"
                                isSwitchedOn: root.manualMode
                                onToggled: function(s) { root.manualMode = s }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: borderColor
                            opacity: 0.2
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            RowLayout {
                                Text {
                                    text: panelUi.yellowDurationLabel || "YELLOW LIGHT DURATION"
                                    color: "#f1c40f"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: root.yellowDuration + "s"
                                    color: "white"
                                    font.pixelSize: 10
                                }
                            }

                            Slider {
                                id: yellowSlider
                                Layout.fillWidth: true
                                from: 1
                                to: 10
                                stepSize: 1
                                value: root.yellowDuration
                                onMoved: root.yellowDuration = value

                                background: Rectangle {
                                    height: 4
                                    radius: 2
                                    color: "#2c3e50"

                                    Rectangle {
                                        width: yellowSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#f1c40f"
                                        radius: 2
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: panelUi.goStreetALabel || "GO STREET A"
                                Layout.fillWidth: true
                                enabled: root.manualMode
                                onClicked: root.activeDir = "A"
                            }

                            Button {
                                text: panelUi.goStreetBLabel || "GO STREET B"
                                Layout.fillWidth: true
                                enabled: root.manualMode
                                onClicked: root.activeDir = "B"
                            }
                        }

                        Button {
                            text: panelUi.allStopLabel || "ALL STOP (RED)"
                            Layout.fillWidth: true
                            enabled: root.manualMode
                            background: Rectangle {
                                radius: 4
                                color: parent.enabled ? "#b22222" : "#221111"
                            }
                            onClicked: root.activeDir = "NONE"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: borderColor
                            opacity: 0.2
                        }

                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: panelUi.signalPersistenceNote || "Signal state is saved to signal_control.json immediately, and external edits reload here automatically."
                            color: textDim
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }

    component HeaderText : Text {
        color: textDim
        font.pixelSize: 10
        font.bold: true
    }

    component BodyText : Text {
        color: textMain
        font.pixelSize: 13
    }

    component HUDSection : Rectangle {
        property string title: ""
        color: "transparent"
        border.color: "#23282e"
        border.width: 2
        radius: 5

        Text {
            text: "- " + parent.title
            color: textDim
            font.pixelSize: 11
            font.bold: true
            x: 10
            y: -8
        }
    }

    component TrafficLight : Column {
        property string label: ""
        property string currentState: "red"

        spacing: 5

        Text {
            text: label
            color: textDim
            font.pixelSize: 9
            font.bold: true
            width: 50
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            width: 42
            height: 96
            color: "#000000"
            radius: 5
            border.color: "#333"

            Column {
                anchors.centerIn: parent
                spacing: 4

                Circle {
                    color: currentState === "red" ? "#ff0000" : "#330000"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Circle {
                    color: currentState === "yellow" ? "#f1c40f" : "#333300"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Circle {
                    color: currentState === "green" ? "#00ff00" : "#003300"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }
    }

    component Circle : Rectangle {
        width: 18
        height: 18
        radius: 9
    }

    component ControlRow : RowLayout {
        id: controlRow
        property string label: ""
        property bool isSwitchedOn: false
        signal toggled(bool newState)

        Text {
            text: label
            color: textMain
            font.pixelSize: 11
            Layout.fillWidth: true
        }

        Switch {
            id: modeSwitch
            checked: controlRow.isSwitchedOn
            onClicked: controlRow.toggled(checked)
            indicator: Rectangle {
                implicitWidth: 32
                implicitHeight: 16
                radius: 8
                color: modeSwitch.checked ? "#4cd964" : "#30363d"

                Rectangle {
                    x: modeSwitch.checked ? 16 : 2
                    y: 2
                    width: 12
                    height: 12
                    radius: 6
                    color: "white"
                }
            }
        }
    }
}
