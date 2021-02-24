import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.valuelogger.Logger 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: valuelogger

    property var plotColors:[ "#ffffff", "#ff0080", "#ff8000", "#ffff00", "#00ff00",
                              "#00ff80", "#00ffff", "#0000ff", "#8000ff", "#ff00ff" ]

    property int lastDataAddedIndex: -1

    property bool plotDraggingActive : false


    initialPage: Component {
        Valuelogger {
            allowedOrientations: valuelogger.allowedOrientations
        }
    }

    cover: Component {
        CoverPage { }
    }

    property string coverIconLeft: "image://theme/icon-cover-new"
    property string coverIconRight: "../icon-cover-plot.png"

    function getBottomPageId() {
        return pageStack.find( function(page) {
            return (page._depth === 0)
        })
    }

    function coverLeftClicked() {
        if ((lastDataAddedIndex != -1) && (lastDataAddedIndex < parameterList.count)) {
            console.log("Adding value to index " + lastDataAddedIndex)

            pageStack.pop(getBottomPageId(), PageStackAction.Immediate)
            /* Remove all except bottom page, Thansk for Acce:
             * https://together.jolla.com/question/44103/how-to-remove-all-except-bottom-page-from-pagestack/#post-id-44117
             */

            var dialog
            dialog = pageStack.push(Qt.resolvedUrl("pages/AddValue.qml"), {
                "allowedOrientations": allowedOrientations,
                "parameterName": parameterList.get(lastDataAddedIndex).parName,
                "parameterDescription": parameterList.get(lastDataAddedIndex).parDescription
            }, PageStackAction.Immediate)

            if (parameterList.get(lastDataAddedIndex).pairedTable !== "") {
                console.log("this is a paired parameter")
                var paired_parName = "ERROR"
                var paired_parDescription = "ERROR"

                for (var i=0; i<parameterList.count; i++) {
                    var tmp = parameterList.get(i)
                    if (tmp.dataTable === parameterList.get(lastDataAddedIndex).pairedTable) {
                        paired_parName = tmp.parName
                        paired_parDescription = tmp.parDescription
                        console.log("found " + tmp.parName + " " + tmp.parDescription)
                        break
                    }
                }

                var pairdialog = pageStack.pushAttached(Qt.resolvedUrl("pages/AddValue.qml"), {
                    "allowedOrientations": allowedOrientations,
                    "nowDate": dialog.nowDate,
                    "nowTime": dialog.nowTime,
                    "parameterName": paired_parName,
                    "parameterDescription": paired_parDescription,
                    "paired": true
                })

                pairdialog.accepted.connect(function() {
                    console.log("paired dialog accepted")
                    console.log(" value is " + pairdialog.value)
                    console.log(" annotation is " + pairdialog.annotation)
                    console.log(" date is " + pairdialog.nowDate)
                    console.log(" time is " + pairdialog.nowTime)

                    logger.addData(parameterList.get(lastDataAddedIndex).pairedTable, "", pairdialog.value, pairdialog.annotation, pairdialog.nowDate + " " + pairdialog.nowTime)
                    valuelogger.deactivate()
                })

                pairdialog.rejected.connect(function() {
                    console.log("Dialog rejected")
                    valuelogger.deactivate()
                })
            }

            dialog.accepted.connect(function() {
                console.log("dialog accepted")
                console.log(" value is " + dialog.value)
                console.log(" annotation is " + dialog.annotation)
                console.log(" date is " + dialog.nowDate)
                console.log(" time is " + dialog.nowTime)

                logger.addData(parameterList.get(lastDataAddedIndex).dataTable, "", dialog.value, dialog.annotation, dialog.nowDate + " " + dialog.nowTime)

                if (parameterList.get(lastDataAddedIndex).pairedTable === "")
                    valuelogger.deactivate()
            })
            dialog.rejected.connect(function() {
                console.log("Dialog rejected")
                valuelogger.deactivate()
            })

            valuelogger.activate()
        }
        else
            console.log("This should never happen")
    }

    function coverRightClicked() {
        console.log("showing data from " + parameterList.get(lastDataAddedIndex).parName)

        var l = []

        parInfo.clear()
        parInfo.append({"name": parameterList.get(lastDataAddedIndex).parName,
                        "plotcolor": parameterList.get(lastDataAddedIndex).plotcolor})
        l.push(logger.readData(parameterList.get(lastDataAddedIndex).dataTable))

        pageStack.pop(getBottomPageId(), PageStackAction.Immediate)
        pageStack.push(Qt.resolvedUrl("pages/DrawData.qml"), {
            "allowedOrientations": allowedOrientations,
            "dataList": l,
            "parInfo": parInfo
        }, PageStackAction.Immediate)

        valuelogger.activate()
    }

    Logger {
        id: logger

        Component.onCompleted: {
            var tmp = logger.readParameters()

            for (var i=0 ; i<tmp.length; i++) {
                var par = tmp[i]

                console.log(i + " = " + par["name"] + " is " + par["plotcolor"] )
                parameterList.append({"parName": par["name"],
                                         "parDescription": par["description"],
                                         "plotcolor": par["plotcolor"],
                                         "dataTable": par["datatable"],
                                         "pairedTable": par["pairedtable"],
                                         "visualize": (par["visualize"] == 1 ? true : false),
                                         "visualizeChanged": false})
            }
        }
    }

    ListModel {
        id: parameterList
    }

    ListModel {
        id: parInfo
    }
}


