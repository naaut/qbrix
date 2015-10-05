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
    property string fileUrl: ""
    property string dataFileUrl: ""
    property string componentName: ""

    property Item codeEditor;

    width: 1280
    height: 768

    FileIO {
        id: fileio
    }

    Watcher {
        id: watcher

        onFileChanged: {
            //console.log("File changed", fileUrl);
            if (codeEditor) codeEditor.reloadText();
            reload();
        }
    }

    Component.onCompleted: {
        componentsFolderModel.folder = folderUrl;
    }

    onFolderUrlChanged: {
        if (codeEditor) codeEditor.destroy(10);
        componentsFolderModel.folder = folderUrl;        
    }

    menuBar: MBar {

    }

    FileDialog {
        id: openDialog
        title: "Please choose a folder"        
        selectFolder: true

        onAccepted: {
            main.folderUrl = openDialog.fileUrl;
        }
    }

    FileDialog {
        id: openFileDialog
        title: "Please choose a image file"
        onAccepted: {
            makeup.idealImage = openFileDialog.fileUrl;
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
                watcher.rmLastFileName();
                fileio.save(text, fileUrl);
                reload(text);               
            });
        }
        else if (component.status == Component.Error) {
            // Error Handling
            console.log("Error loading component:", component.errorString());
        }
    }

    //Reload component
    function reload(text, dataFileName) {
        var source = makeup.componentLoader.source;
        makeup.componentLoader.source = "";
        cacheManager.clear();
        makeup.componentLoader.setSource(source, Helper.tryParseJSON(text));

        if (dataFileName) watcher.fileName =  dataFileName;
        else watcher.fileName =  fileUrl;
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
            makeup.componentLoader.setSource(main.fileUrl, testData);
            loadCode(dataFileUrl);
            watcher.fileName = dataFileUrl;
        }
        else  {
            testDataTable.selection.clear();
            makeup.componentLoader.setSource(main.fileUrl, {});
            loadCode(fileUrl);
            watcher.fileName =  fileUrl;
        }
    }

    // Apply JSON Data to component
    function applyData() {
        testDataFolderModel.selection = testDataTable.selection;
        testDataTable.model.selection.forEach(function (rowIndex) {
            dataFileUrl = main.folderUrl + "/TestData/" + componentName + "/" + testDataTable.model.get(rowIndex, "fileName");
        });
        var TestData = Helper.tryParseJSON(fileio.load(dataFileUrl));
        loadComponent(TestData);
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
                model: testDataFolderModel
            }
        }

        Makeup {
            id: makeup
            width: 800
        }

        Rectangle {
            id: editArea

        }
    }
}

