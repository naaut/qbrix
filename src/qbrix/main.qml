import QtQuick 2.5
import QtQuick.Window 2.2


import QtQuick.Controls 1.2
import Qt.labs.folderlistmodel 2.1

Window {
    id: main
    visible: true



        width: 900
        height: 600

        Component.onCompleted: {
            elementsModel.selection = elementSetTable.selection;
            testDataModel.selection = dataSetTable.selection;
        }

        // Load List of Avalible DataSet
        function loadDataSets() {
            elementSetTable.model.selection.forEach(function (rowIndex) {
                testDataModel.folder = elementSetTable.model.get(rowIndex, "fileName") + "/TestData";
            })
        }

        // Load selected component
        function loadComponent() {
            elementSetTable.model.selection.forEach(function (rowIndex) {
               var name = elementSetTable.model.get(rowIndex, "fileName");
               componentLoader.source = name + "/" + name + ".qml";
            })
        }



        SplitView {
            id: splitView
            anchors.fill: parent


            Column {

                width: 200

                TableView {

                    id: elementSetTable

                    height: main.height/2
                    anchors.right: parent.right
                    anchors.left: parent.left

                    TableViewColumn {
                        role: "fileName"
                        title: qsTr("Element Name")
                    }

                    FolderListModel {

                        id: elementsModel

                        property QtObject selection

                        nameFilters: ["*"]
                        showFiles: false
                    }

                    onClicked: {
                        // Load List of Avalible DataSet
                        loadDataSets();
                        loadComponent() ;
                    }

                    model: elementsModel
                }

                TableView {

                    id: dataSetTable

                    width: elementSetTable.width
                    height: main.height/2



                    TableViewColumn {
                        role: "fileName"
                        title: qsTr("Data Sets")
                    }

                    FolderListModel {

                        id: testDataModel

                        property QtObject selection

                        nameFilters: ["*.json"]
                        showDirs: false
                    }

                    onClicked: {
                        console.log(">>>>>>>>>>>>>>>> onClicked")
                    }

                    onDoubleClicked: {
                        console.log(">>>>>>>>>>>>>>>> onDoubleClicked")
                    }

                    model: testDataModel
                }
            }

            Rectangle {
                color:"darkgrey"

                Loader{
                    id: componentLoader

                    anchors.centerIn: parent
                }
            }
        }

}

