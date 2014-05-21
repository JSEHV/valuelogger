import QtQuick 2.0
import Sailfish.Silica 1.0
import valuelogger.Logger 1.0

Page
{
    id: page

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "About..."
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"),
                                          { "version": logger.version,
                                              "year": "2014",
                                              "name": "Value Logger",
                                              "imagelocation": "/usr/share/icons/hicolor/86x86/apps/valuelogger.png"} )
            }
        }

        contentHeight: column.height

        ListModel
        {
            id: parameterList
        }

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader
            {
                title: "Valuelogger"
            }

            Button
            {

                text: "Add new parameter"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    var dialog = pageStack.push(Qt.resolvedUrl("NewParameter.qml"))
                    dialog.accepted.connect(function()
                    {
                        console.log("dialog accepted")
                        console.log(dialog.parameterName)
                        console.log(dialog.parameterDescription)
                        parameterList.append({"name": dialog.parameterName,
                                                 "description": dialog.parameterDescription,
                                                 "visualize": true })
                    } )

                }
            }
        }

        ListView
        {
            id: parameters
            width: parent.width
            height: 6*Theme.itemSizeMedium
            clip: true

            VerticalScrollDecorator { flickable: parameters }

            model: parameterList

            anchors.top: column.bottom

            delegate: ListItem
            {
                id: parameterItem
                menu: contextMenu
                contentHeight: Theme.itemSizeMedium // two line delegate

                ListView.onRemove: animateRemoval(listItem)

                function remove()
                {
                    remorseAction("Deleting", function() { parameters.model.remove(index) })
                }

                Row
                {
                    x: Theme.paddingMedium
                    Switch
                    {
                        id: parSwitch
                        checked: visualize
                    }

                    Column
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        Label
                        {
                            id: parNameLabel
                            text: name
                            color: parameterItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label
                        {
                            text: description
                            font.pixelSize: Theme.fontSizeSmall
                            color: parameterItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                        }
                    }
                }

                Component
                {
                    id: contextMenu
                    ContextMenu
                    {
                        MenuItem
                        {
                            text: "Remove"
                            onClicked: remove()
                        }
                    }
                }
            }


        }

        Button
        {
            text: "Visualize"
            onClicked:
            {
                console.log("there is " + parameterList.count + " items in list.")
                var a
                for (a=0; a<parameterList.count; a++)
                {
                    console.log(parameterList.get(a))
                }
            }
            anchors.top: parameters.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Logger
    {
        id: logger
    }
}


