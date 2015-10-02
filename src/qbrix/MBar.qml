import QtQuick 2.0
import QtQuick.Controls 1.2


MenuBar {
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
            text: "Open Image"
            shortcut: "Ctrl+I"
            onTriggered: {
                openFileDialog.open();
            }
        }

        MenuItem {
            text: "Quit"
            onTriggered: Qt.quit()
        }
    }

//    Menu {
//        title: "Options"

//        MenuItem {
//            text: "Clear Debug Rect"
//            shortcut: "Ctrl+Q"
//            onTriggered: {

//            }
//        }

//        MenuItem {
//            text: "Clear All"
//            shortcut: "Ctrl+W"
//            onTriggered: {

//            }
//        }

//        MenuItem {
//            text: "Something1"
//            shortcut: "Crtl+E"
//            onTriggered: {

//            }
//        }

//        MenuItem {
//            text: "Something2"
//            shortcut: "Crtl+R"
//            onTriggered: {

//            }
//        }
//    }
}
