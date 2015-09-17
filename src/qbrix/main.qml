import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import CustomClasses 1.0
import Qt.labs.folderlistmodel 2.1

ApplicationWindow {

    property string folderUrl: "file://D:/Git/qbrix/resources"
    property string fileUrl: "file:///work/qbrix/resources/Button.qml"
    property string dataFileUrl: "file:///cwork/qbrix/resources/TestData/Button/ButtonDataSet.json"

    property variant win;

    id: main
    visible: true

    width: 900
    height: 600

    FileIO{
        id: fileio
    }

    Component.onCompleted: {
        console.log(">>>>> Component.onCompleted folderUrl ", Qt.resolvedUrl(folderUrl));
         componentsFolderModel.folder = folderUrl;
    }

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
        title: "Please choose a file"
        //folder: shortcuts.home
        selectFolder: true

        onAccepted: {
            console.log("You chose: " + openDialog.fileUrl)
            main.folderUrl = openDialog.fileUrl;
            console.log(">>>>> onAccepted main.folderUrl ", folderUrl);
        }
    }

    function createNewWindow(fileUrl) {
        var component = Qt.createComponent("EditWindow.qml");
        if (component.status == Component.Ready){
            win = component.createObject(main);
            win.show();
            win.folderUrl = main.folderUrl;
            win.fileUrl = fileUrl;

            win.textChanged.connect(function(text){
                    var source = componentLoader.source;
                    componentLoader.source = "";
                    cacheManager.clear();
                    console.log(">>>>> Trim" )
                    fileio.save(text, source)
                    componentLoader.source = source;

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
            if (testData) componentLoader.setSource(main.fileUrl, testData);
            else  componentLoader.setSource(main.fileUrl, {});
        });
    }

    //apply data Sets
    function applyData() {
        var componentName;
        testDataFolderModel.selection = testDataTable.selection;
        componentsSetTable.model.selection.forEach(function (rowIndex) {
            componentName = componentsSetTable.model.get(rowIndex, "fileName").replace(".qml" ,"");
        });
        testDataTable.model.selection.forEach(function (rowIndex){
            dataFileUrl = main.folderUrl + "/TestData/" + componentName + "/" + testDataTable.model.get(rowIndex, "fileName")
            var TestData = JSON.parse(fileio.load(dataFileUrl));
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

                onActiveFocusOnTabChanged: {

                }

//                onCurrentRowChanged: {
//                    // Load List of Avalible DataSet
//                    loadDataSets();
//                    loadComponent();
//                }

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

            Loader{
                id: componentLoader
                x: parent.width/2 - componentLoader.width/2
                y: parent.height/2 - componentLoader.height/2
                //anchors.centerIn: parent
            }
        }
    }
}

