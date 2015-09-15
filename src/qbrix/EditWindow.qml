import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import CustomClasses 1.0

ApplicationWindow {

    id: editWindow

    property string fileUrl: ""
    property string folderUrl: ""

    width: 900
    height: 600

    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Save"
                shortcut: "Ctrl+S"
                onTriggered: {
                    fileio.save(edit.text,fileUrl.replace("file://",""));
                }
            }
        }
    }

    TextEdit {
        id: edit
        anchors.fill: parent

    }

    onFileUrlChanged: {
        edit.text = fileio.load(fileUrl.replace("file://",""));
    }
}
