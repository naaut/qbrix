import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import CustomClasses 1.0

ApplicationWindow {

    id: editWindow

    property string fileUrl: ""
    property string folderUrl: ""

    //signal textChanged(var text);

    width: 900
    height: 600

    FileIO{
        id: fileio
    }

    menuBar: MenuBar {

        Menu {
            title: "File"

            MenuItem {
                text: "Save"
                shortcut: "Ctrl+S"
                onTriggered: {
                    fileio.save(edit.text, fileUrl);
                }
            }
        }
    }

    CodeEditor{
        id: edit

    }

    onFileUrlChanged: {        
        edit.text = fileio.load(fileUrl);
    }
}



