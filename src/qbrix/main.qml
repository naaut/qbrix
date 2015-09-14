import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import CustomClasses 1.0
import Qt.labs.folderlistmodel 2.1

ApplicationWindow {
    id: main
    visible: true

    width: 900
    height: 600

    FileIO{
        id: fileio
    }


    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Open"
                onTriggered: {
                    openDialog.open();
                }
            }

            MenuItem {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: "Please choose a file"
        folder: shortcuts.home
        selectFolder: true

        onAccepted: {
            console.log("You chose: " + openDialog.fileUrl)
            componentsFolderModel.folder = openDialog.fileUrl;
        }
    }


    // Load List of Avalible DataSet
    function loadDataSets() {
        componentsFolderModel.selection = componentsSetTable.selection;
        testDataTable.selection.clear();
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            var name = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
            testDataFolderModel.folder = openDialog.fileUrl+ "/TestData/" + name;
        });
    }

    // Load selected component
    function loadComponent(testData) {
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            var name = componentsSetTable.model.get(rowIndex, "fileName");
            if (testData) componentLoader.setSource(openDialog.fileUrl + "/" + name, testData);
            else  componentLoader.setSource(openDialog.fileUrl + "/" + name, {});
        });
    }

    //apply data Sets
    function applyData() {
        var name;
        testDataFolderModel.selection = testDataTable.selection;
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            name = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
        });
        testDataTable.model.selection.forEach(function (rowIndex){
            var fileName = openDialog.fileUrl + "/TestData/" + name + "/" + testDataTable.model.get(rowIndex, "fileName")
            var TestData = JSON.parse(fileio.load(fileName.replace("file://","")));
            loadComponent(TestData);
        });

    }


    SplitView {
        id: splitView
        anchors.fill: parent


        Column {

            width: 200

            TableView {
                id: componentsSetTable

                height: main.height/2
                anchors.right: parent.right
                anchors.left: parent.left

                TableViewColumn {
                    role: "fileName"
                    title: qsTr("Element Name")
                }

                FolderListModel {

                    id: componentsFolderModel

                    property QtObject selection

                    nameFilters: ["*.qml"]
                    showDirs: false
                }

                onClicked: {
                    // Load List of Avalible DataSet
                    loadDataSets();
                    loadComponent();

                }

                model: componentsFolderModel
            }

            TableView {
                id: testDataTable

                width: componentsSetTable.width
                height: main.height/2

                TableViewColumn {
                    role: "fileName"
                    title: qsTr("Data Sets")
                }

                FolderListModel {
                    id: testDataFolderModel

                    property QtObject selection

                    nameFilters: ["*.json"]
                    showDirs: false
                }

                onClicked: {
                    applyData();
                }

                onDoubleClicked: {

                }

                model: testDataFolderModel
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

