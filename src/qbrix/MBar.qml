import QtQuick 2.0
import QtQuick.Controls 1.2


/*!
 \brief
    ctrl + O             Выбрать директорию с компонентами
    ctrl + I             Открыть Ideal
    ctrl + E             Сменить Z ideal и component
    ctrl + 5             изменить режим измерения квадратиком (пиксели/проценты)
    ctrl + 2             удалить измеряющий квадратик
    ctrl + W             установить зум в 1
    ctrl + 3             удалить картинку
    ctrl + 4             установить зум в 1, отцентрировать квадрат, компонент и картинку
    ctrl + 1             сбросить зум, удалить картинку
    ctrl + upArrow       переключиться на дизайн
    ctrl + downArrow     переключиться на верстку
 */


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
            text: "Quit"
            onTriggered: Qt.quit()
        }
    }

    Menu {
        title: "Options"

        MenuItem {
            text: "Clear All"
            shortcut: "Ctrl+1"
            onTriggered: {
                makeup.clearDebugRect();
                makeup.clearIdeal();
                makeup.resetScale();
            }
        }

        MenuItem {
            text: "Clear Debug Rec"
            shortcut: "Ctrl+2"
            onTriggered: {
                makeup.clearDebugRect();
            }
        }

        MenuItem {
            text: "Set At Center"
            shortcut: "Ctrl+4"
            onTriggered: {
                makeup.setAtCenter();
            }
        }

        MenuItem {
            text: "Change Mode"
            shortcut: "Ctrl+5"
            onTriggered: {
                makeup.changeMode();
            }
        }

        MenuItem {
            text: "Reset Scale"
            shortcut: "Ctrl+W"
            onTriggered: {
                makeup.resetScale();

            }
        }

        MenuItem {
            text: "Change Z"
            shortcut: "Ctrl+E"
            onTriggered: {
                makeup.changeZ();
            }
        }
    }

    Menu {
        title: "Ideal"

        MenuItem {
            text: "Open Image"
            shortcut: "Ctrl+I"
            onTriggered: {
                openFileDialog.open();
            }
        }

        MenuItem {
            text: "Clear Ideal Image"
            shortcut: "Ctrl+3"
            onTriggered: {
                makeup.clearIdeal();
            }
        }

        MenuItem {
            text: "+0.5 Opacity"
            shortcut: "Ctrl+Up"
            onTriggered: {
                makeup.idealOpacity += 0.5;
            }
        }

        MenuItem {
            text: "-0.5 Opacity"
            shortcut: "Ctrl+Down"
            onTriggered: {
                makeup.idealOpacity -= 0.5;
            }
        }
    }
}
