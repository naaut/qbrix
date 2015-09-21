import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import CustomClasses 1.0
import Qt.labs.folderlistmodel 2.1
import "Helper.js" as Helper



ApplicationWindow {
    id: editWindow
    visible: true

    property string folderUrl: "file:///work/qbrix/resources"
    property string fileUrl: "file:///work/qbrix/resources/Button.qml"

    width: 1280
    height: 768

    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Save File"
                shortcut: "Ctrl+S"
                onTriggered: {

                }
            }

            MenuItem {
                text: "Quit"
                shortcut: "Crtl+X"
                onTriggered: editWindow.close();
            }
        }
    }

    FileDialog {
        id: openDialog
        title: "Please choose a file"
        onAccepted: {
            editWindow.fileUrl = openDialog.fileUrl;
        }
    }



}
