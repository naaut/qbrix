import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import CustomClasses 1.0
import Qt.labs.folderlistmodel 2.1
import "Helper.js" as Helper



ApplicationWindow {

    property string folderUrl: "file:///work/qbrix/resources"
    property string fileUrl: "file:///work/qbrix/resources/Button.qml"
    property string dataFileUrl: "file:///work/qbrix/resources/TestData/Button/ButtonDataSet.json"

    property variant win;
    property variant codeEditor;

    id: main
    visible: true

    width: 1280
    height: 768

    FileIO{
        id: fileio
    }

    Component.onCompleted: {
         componentsFolderModel.folder = folderUrl;
    }

//    onFolderUrlChanged: {
//        if (codeEditor) codeEditor.destroy();
//        cacheManager.clear();
//        componentsFolderModel.folder = "";
//        componentsFolderModel.folder = folderUrl;
//    }



    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Open"
                shortcut: "Ctrl+O"
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
        title: "Please choose a folder"
        folder: shortcuts.home
        selectFolder: true

        onAccepted: {
            console.log("You chose: " + openDialog.fileUrl)
            main.folderUrl = openDialog.fileUrl;

        }
    }

    //creating new CodeEdit and load code
    function loadCode(fileUrl , isJSON) {
        var component = Qt.createComponent("CodeEditor.qml");
        if (component.status == Component.Ready){
            if (codeEditor) codeEditor.destroy();
            codeEditor = component.createObject(editArea);
            codeEditor.fileUrl = fileUrl;
            codeEditor.dataChanged.connect(function (text){
                var source = componentLoader.source;
                componentLoader.source = "";
                cacheManager.clear();
                fileio.save(text, fileUrl);
                if (isJSON) componentLoader.setSource(source, Helper.parseJSON(text));
                else componentLoader.source = source;
            });
        }
        else if (component.status == Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }
    }

    // Load List of Avalible DataSet
    function loadDataSets() {
        componentsFolderModel.selection = componentsSetTable.selection;
        testDataTable.selection.clear();
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            var name = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
            testDataFolderModel.folder = main.folderUrl + "/TestData/" + name;
        });
    }

    // Load selected component
    function loadComponent(testData) {        
        componentLoader.source = "";
        cacheManager.trim();
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            main.fileUrl = main.folderUrl + "/" + componentsSetTable.model.get(rowIndex, "fileName");
            if (testData) {
                loadCode(dataFileUrl, true);
                componentLoader.setSource(main.fileUrl, testData);
            }
            else  {
                loadCode(fileUrl);
                componentLoader.setSource(main.fileUrl, {});
            }
        });
    }

    // Apply JSON Data to component
    function applyData() {        
        var componentName;
        testDataFolderModel.selection = testDataTable.selection;
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            componentName = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
        });
        testDataTable.model.selection.forEach(function (rowIndex){
            dataFileUrl = main.folderUrl + "/TestData/" + componentName + "/" + testDataTable.model.get(rowIndex, "fileName")

            var TestData = Helper.parseJSON(fileio.load(dataFileUrl));
            if (TestData === {}) loadCode(dataFileUrl);
            else loadComponent(TestData);

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
                onDoubleClicked: {                    
                    createNewWindow(fileUrl);
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
                    createNewWindow(dataFileUrl);
                }

                model: testDataFolderModel
            }
        }

        Rectangle {
            color:"darkgrey"
            width: 400

            Loader{
                id: componentLoader
                x: parent.width/2 - componentLoader.width/2
                y: parent.height/2 - componentLoader.height/2
               // anchors.centerIn: parent
            }
        }

        Rectangle {
            id: editArea

        }
    }
}

