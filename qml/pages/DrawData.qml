import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property var dataList : []
    property var parInfo : null

    backNavigation: !plotDraggingActive

    PageHeader {
        id: ph
        title: qsTr("Plot")
    }

    LinePlot {
        dataListModel: dataList
        parInfoModel: parInfo
        id: plot
        width: parent.width - Theme.paddingLarge
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge/2
        anchors.top: ph.bottom
        anchors.bottom: parent.bottom
    }
}

