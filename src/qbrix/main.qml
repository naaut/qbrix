import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import CustomClasses 1.0
import Qt.labs.folderlistmodel 2.1
import "Helper.js" as Helper



ApplicationWindow {    
    id: main
    visible: true

    property string folderUrl: "file:///work/qbrix/resources"
    property string fileUrl: "file:///work/qbrix/resources/Button.qml"
    property string dataFileUrl: "file:///work/qbrix/resources/TestData/Button/ButtonDataSet.json"
    property string componentName: ""

    property variant codeEditor;
    property variant editWindow;

    width: 1280
    height: 768

    FileIO{
        id: fileio
    }

    Component.onCompleted: {
         componentsFolderModel.folder = folderUrl;
    }

    onFolderUrlChanged: {
        if (codeEditor) codeEditor.destroy();        
        componentsFolderModel.folder = folderUrl;
    }

    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Open Folder"
                shortcut: "Ctrl+O"
                onTriggered: {
                    openDialog.open();
                }
            }

            MenuItem {
                text: "Create File"
                shortcut: "Ctrl+N"
                onTriggered: {
                    var component = Qt.createComponent("EditWindow.qml");
                    if (component.status == Component.Ready){
                        editWindow = component.createObject(main);
                        editWindow.folderUrl = folderUrl;
                    }
                    else if (component.status == Component.Error) {
                        // Error Handling
                        console.log("Error loading component:", component.errorString());
                    }
                }
            }

            MenuItem {
                text: "Quit"
                shortcut: "Crtl+X"
                onTriggered: Qt.quit()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: "Please choose a folder"        
        selectFolder: true

        onAccepted: {
            main.folderUrl = openDialog.fileUrl;
        }
    }

    //creating new CodeEdit and load code
    function loadCode(fileUrl) {
        var component = Qt.createComponent("CodeEditor.qml");
        if (component.status == Component.Ready){
            if (codeEditor) codeEditor.destroy();
            codeEditor = component.createObject(editArea);
            codeEditor.fileUrl = fileUrl;
            codeEditor.dataChanged.connect(function (text){
            var source = componentLoader.source;
                fileio.save(text, fileUrl);
                componentLoader.source = "";
                cacheManager.clear();
                componentLoader.setSource(source, Helper.tryParseJSON(text));
            });
        }
        else if (component.status == Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }
    }

    // Load selected component
    function loadComponent(testData) {
        componentsFolderModel.selection = componentsSetTable.selection;
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            main.fileUrl = main.folderUrl + "/" + componentsSetTable.model.get(rowIndex, "fileName");
            componentName = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
        });

        testDataFolderModel.folder = main.folderUrl + "/TestData/" + componentName;
        if (testData) {
            loadCode(dataFileUrl);
            componentLoader.setSource(main.fileUrl, testData);
        }
        else  {
            testDataTable.selection.clear();
            loadCode(fileUrl);
            componentLoader.setSource(main.fileUrl, {});
        }
    }

    // Apply JSON Data to component
    function applyData() {
        testDataFolderModel.selection = testDataTable.selection;
        testDataTable.model.selection.forEach(function (rowIndex) {
            dataFileUrl = main.folderUrl + "/TestData/" + componentName + "/" + testDataTable.model.get(rowIndex, "fileName");
        });
        var TestData = Helper.tryParseJSON(fileio.load(dataFileUrl));
        if (TestData === {}) loadCode(dataFileUrl);
        else loadComponent(TestData);
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
                    // Load List of Avalible DataSet and Load component
                    //loadDataSets();
                    loadComponent();
                }
                onDoubleClicked: {                    

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
            width: 400

            Loader{
                id: componentLoader
                x: parent.width/2 - componentLoader.width/2
                y: parent.height/2 - componentLoader.height/2
                // anchors.centerIn: parent

                MouseArea {
                    id: mouseArea
                    anchors.fill: componentLoader
                    drag.target: componentLoader
                }
            }
        }

        Rectangle {
            id: editArea

        }
    }
}

