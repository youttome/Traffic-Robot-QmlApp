import QtQuick

Item {
    id: root

    readonly property real fallbackPerformance: typeof performance_value !== "undefined" ? performance_value : 0
    readonly property real cpuUsagePercent: dataManager.systemHealth && dataManager.systemHealth.cpuUsage !== undefined
        ? Number(dataManager.systemHealth.cpuUsage)
        : fallbackPerformance * 100
    readonly property real performanceValue: Math.max(0, Math.min(1, cpuUsagePercent / 100))

    CircleBar {
        id: circleBar
        anchors.fill: parent
        value: root.performanceValue
        barHeight: 0.34
        barsAmount: 96
        highlightColor: Qt.rgba(0.15 + value * 0.55, 0.75 - value * 0.25, 0.95, 1.0)
        startAngle: Math.PI * 1.5 - spanAngle * 0.5
        spanAngle: 5.1
        glowBloom: 1.4
        glowBlur: 1.0
        barsSmoothness: 1.2
        barsDistribution: 0.55
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.1
        color: "#f0f6ff"
        font.pixelSize: Math.max(16, parent.height * 0.18)
        font.bold: true
        text: Math.round(root.cpuUsagePercent) + "%"
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height * 0.14
        color: "#89c2ff"
        font.pixelSize: Math.max(10, parent.height * 0.08)
        font.letterSpacing: 1.8
        text: "CPU LOAD"
    }
}
