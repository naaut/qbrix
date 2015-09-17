import QtQuick 2.5
import QtQuick.Controls 1.2
import CustomClasses 1.0

ScrollView {
    id: scrollView

   anchors.fill: parent

    property string fileUrl: ""

    signal dataChanged(var text);


    onFileUrlChanged: {
        edit.text = dataFileIO.load(fileUrl);
    }

    MouseArea {

        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

    }

    TextEdit {
        id: edit

        color: palette.editorNormal
        selectionColor: palette.editorSelection
        selectedTextColor: palette.editorSelectedText
        inputMethodHints: Qt.ImhNoPredictiveText
        selectByMouse : true

        Timer {
            id: timer
            interval: 400
            onTriggered:  {
                scrollView.dataChanged(edit.text);
            }
        }

        onTextChanged: {
            timer.stop()
            timer.start()
        }

        Component.onCompleted: {
            syntaxHighlighter.setHighlighter(edit);
        }



        FileIO{
            id: dataFileIO
        }

        SyntaxHighlighter {
            id: syntaxHighlighter

            normalColor: palette.editorNormal
            commentColor: palette.editorComment
            numberColor: palette.editorNumber
            stringColor: palette.editorString
            operatorColor: palette.editorOperator
            keywordColor: palette.editorKeyword
            builtInColor: palette.editorBuiltIn
            markerColor: palette.editorMarker
            itemColor: palette.editorItem
            propertyColor: palette.editorProperty
        }

        QtObject {
            id: palette

            property color background: "#eeeeee"

            property color toolBarBackground: "#ffffff"
            property color toolBarStripe: "#aaaaaa"
            property color toolBarShadowBegin: "#30000000"
            property color toolBarShadowEnd: "#00000000"

            property color label: "#000000"
            property color description: "#222222"
            property color icon: "#000000"
            property color warning: "#ff0000"
            property color link: "#777777"

            property color textFieldBackground: "#ffffff"
            property color textFieldBorder: "#cccccc"
            property color textFieldPlaceholder: "#aaaaaa"
            property color textFieldSelection: "#aaaaaa"

            property color button: "#aaaaaa"

            property color separator: "#cccccc"

            property color scrollBar: "#30000000"

            property color dialogOverlay: "#30000000"
            property color dialogBackground: "#ffffff"
            property color dialogShadow: "#ff000000"

            property color sliderFilledStripe: "#000000";
            property color sliderEmptyStripe: "#aaaaaa";
            property color sliderHandle: "#ffffff"
            property color sliderHandleBorder: "#555555"

            property color tooltipBackground: "#cc000000"
            property color tooltipText: "#ffffff"

            property color switcherBackground: "#ffffff"
            property color switcherBorder: "#cccccc"
            property color switcherHandle: "#dddddd"

            property color contextMenuButton: "#cc000000"
            property color contextMenuButtonPressed: "#ff000000"
            property color contextMenuButtonText: "#ffffff"

            property color lineNumbersBackground:"#dddddd"
            property color lineNumber: "#aaaaaa"

            property color editorSelection: "#aaaaaa"
            property color editorSelectedText: "#ffffff"

            property color editorSelectionHandle: "#777777"

            property color editorNormal: "#000000"
            property color editorComment: "#008000"
            property color editorNumber: "#000080"
            property color editorString: "#008000"
            property color editorOperator: "#000000"
            property color editorKeyword: "#808000"
            property color editorBuiltIn: "#0055af"
            property color editorMarker: "#ffff00"
            property color editorItem: "#800080"
            property color editorProperty: "#800000"
        }
    }
}







