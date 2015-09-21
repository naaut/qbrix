import QtQuick 2.4

/*!
 \brief Помощник верстальщика
    ctrl + mousePress    рисовать измеряющий квадратик
    ctrl + p             изменить режим измерения квадратиком (пиксели/проценты)
    ctrl + wheel         зум (изменить размер окна)
    ctrl + upArrow       переключиться на дизайн
    ctrl + downArrow     переключиться на верстку

    квадратик можно передвигать и растягивать (изменять размеры)

    полезности:
    1. выставить размеры окна, как у png'шки
        rootAppWindow.height = 616;
        rootAppWindow.width = 360;
    2. стандартный путь до картинок в ресурсах
        idealImage: app.currentRegion.commonResourcesUrl + "/images/name.png"
 */

// @TODO причесать как следует
Item {

    Ui{
        id: ui
    }

    //anchors.fill: parent
    property var modes: ({
        PX: 0,
        PP: 1
    })
    property int mode: modes.PX
    /*!
     \brief возвращает следующее за `current` значение из enum'a `list`
     \param type:object
     \param type:int
     \return type:int
     */
    function next(list, current) {
        var n = current + 1;
        if (n === Object.keys(list).length) {
            n = 0;
        }
        return n;
    }
    function nameMode() {
        switch (mode) {
        case modes.PX: return 'px';
        case modes.PP: return '%';
        }
    }
    function getSize(v) {
        switch (mode) {
        case modes.PX:
            return Math.floor(v);
        case modes.PP:
            return ui.px2pph(v).toFixed(2);
        }
    }

    property alias idealImage: ideal.source
    property bool ctrl: false
    Component.onCompleted: {

        forceActiveFocus();
    }
    onActiveFocusChanged: if (!activeFocus) forceActiveFocus()
    Keys.onUpPressed: ideal.opacity += 0.5
    Keys.onDownPressed: ideal.opacity -= 0.5
    Keys.onLeftPressed: {
        debugRect.x = debugRect.y = debugRect.width = debugRect.height = 0;
    }

    Keys.onPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            mainMouse.cursorShape = Qt.CrossCursor;

            switch (event.key) {
            // 0
            case 48:
                // @TODO сломано
                ideal.width = d.idealW;
                ideal.height = d.idealH;
                rootAppWindow.width = d.rootW;
                rootAppWindow.height = d.rootH;
                debugRect.width = 1.1;
                debugRect.height = 1.1;
                debugRect.x = 1.1;
                debugRect.y = 1.1;
                Ui.dpimult = 1;
                break;
            // P
            case 80:
                mode = next(modes, mode);
                d.updateDebugInfo();
                break;
            }
        }
    }
    Keys.onReleased: {
        mainMouse.cursorShape = Qt.ArrowCursor;
    }
    Image {
        id: ideal
        opacity: 0.5
    }
    QtObject {
        id: d
        property real x_: 0
        property real y_: 0
        property real w
        property real h
        property bool isDrawing: false
        property var draggingElement
        property int resizingCorner: -1
        // когда объект ресайзится — это офсет от точки, в которой уголок схватили, до origin точки уголка
        property real resizingOffsetX: 0
        property real resizingOffsetY: 0
        // когда объект драгается — это офсет от точки, в которой объект схватили, до origin точки объекта
        property real draggingOffsetX: 0
        property real draggingOffsetY: 0
        readonly property real rootW: main.width
        readonly property real rootH: main.height
        readonly property real idealW: ideal.width
        readonly property real idealH: ideal.height
        function getWidth(x1, x2) {
            return Math.abs(x1 - x2);
        }
        function getHeight(y1, y2) {
            return Math.abs(y1 - y2);
        }
        function updateDebugInfo() {
            debugInfo.text = 'w:'+getSize(d.w)+' h:'+getSize(d.h)+' (' + nameMode() + ')';
        }
    }
    /*!
      \brief точка (x,y) находится внутри элемента `target`
          -----------
          |         |
          |         |
          |         |
          |      *  |
          |         |
          -----------
       \return type:bool
      */
    function insideObject(x, y, target) {
        return inside(x, y, target.x, target.y, target.width, target.height);
    }
    function inside(x, y, ox, oy, ow, oh) {
        return x > ox &&
               x < ox + ow &&
               y > oy &&
               y < oy + oh;
    }
    /*!
      \brief точка (mouseX, mouseY) находится в одном из четырех углов (угол — 1/16 прямоугольника)
          ---------------------
          |    |    |    |    |
          |  * |    |    | *  |
          ---------------------
          |    |    |    |    |
          |    |    |    |    |
          ---------------------
          |    |    |    |    |
          |    |    |    |    |
          ---------------------
          |  * |    |    | *  |
          |    |    |    |    |
          ---------------------
      \return type:int 0: upper left, 1: upper right,
                       2: bottom left, 3: bottom right
      */
    function whichCornerHovered(mouseX, mouseY) {
        for (var i = 0; i < corner.positions.length; i++) {
            var c = corner.positions[i];
            if (inside(mouseX, mouseY, c.x, c.y, corner.width, corner.height)) {
                return i;
            }
        }
        corner.visible = false;
    }
    function updateElement(mouseX, mouseY, target) {
        target.x = mouseX - d.draggingOffsetX;
        target.y = mouseY - d.draggingOffsetY;
    }
    /*!
      \param type:int cornerPos 0: upper left, 1: upper right,
                                2: bottom left, 3: bottom right
      */
    function resizeRect(mouseX, mouseY, cornerPos) {
        var offsetX, offsetY;
        switch (cornerPos) {
        case corner._UPPER_LEFT:
            offsetX = debugRect.x - (mouseX - d.resizingOffsetX);
            offsetY = debugRect.y - (mouseY - d.resizingOffsetY);
            debugRect.x -= offsetX;
            debugRect.y -= offsetY;
            debugRect.width += offsetX;
            debugRect.height += offsetY;
            break;
        case corner._UPPER_RIGHT:
            offsetX = debugRect.x - ((mouseX + d.resizingOffsetX) - debugRect.width);
            offsetY = debugRect.y - (mouseY - d.resizingOffsetY);
            debugRect.y -= offsetY;
            debugRect.width -= offsetX;
            debugRect.height += offsetY;
            break;
        case corner._BOTTOM_LEFT:
            offsetX = debugRect.x - (mouseX - d.resizingOffsetX);
            offsetY = debugRect.y - ((mouseY + d.resizingOffsetY) - debugRect.height);
            debugRect.x -= offsetX;
            debugRect.width += offsetX;
            debugRect.height -= offsetY;
            break;
        case corner._BOTTOM_RIGHT:
            offsetX = debugRect.x - ((mouseX + d.resizingOffsetX) - debugRect.width);
            offsetY = debugRect.y - ((mouseY + d.resizingOffsetY) - debugRect.height);
            debugRect.width -= offsetX;
            debugRect.height -= offsetY;
            break;
        }

        d.w = debugRect.width;
        d.h = debugRect.height;
        d.updateDebugInfo();

        corner.updateSize();
    }
    /*!
      \param type:int cornerPos 0: upper left, 1: upper right,
                                2: bottom left, 3: bottom right
      */
    function startResizing(mouseX, mouseY, cornerPos) {
        d.resizingCorner = cornerPos;
        switch (cornerPos) {
        case corner._UPPER_LEFT:
            d.resizingOffsetX = mouseX - corner.positions[cornerPos].x;
            d.resizingOffsetY = mouseY - corner.positions[cornerPos].y;
            break;
        case corner._UPPER_RIGHT:
            d.resizingOffsetX = corner.positions[cornerPos].x + corner.width - mouseX;
            d.resizingOffsetY = mouseY - corner.positions[cornerPos].y;
            break;
        case corner._BOTTOM_LEFT:
            d.resizingOffsetX = mouseX - corner.positions[cornerPos].x;
            d.resizingOffsetY = corner.positions[cornerPos].y + corner.height - mouseY;
            break;
        case corner._BOTTOM_RIGHT:
            d.resizingOffsetX = corner.positions[cornerPos].x + corner.width - mouseX;
            d.resizingOffsetY = corner.positions[cornerPos].y + corner.height - mouseY;
            break;
        }
    }
    function stopResizing() {
        d.resizingCorner = -1;
        d.resizingOffsetX = 0;
        d.resizingOffsetY = 0;
    }
    function startDragging(mouseX, mouseY, target) {
        d.draggingElement = target;
        d.draggingOffsetX = mouseX - target.x;
        d.draggingOffsetY = mouseY - target.y;
    }
    function stopDragging() {
        d.draggingElement = null;
        d.draggingOffsetX = 0;
        d.draggingOffsetY = 0;
    }
    function stopDrawing() {
        d.isDrawing = false;
        corner.updateSize();
    }
    MouseArea {
        id: mainMouse
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        onPressed: {
            if (insideObject(mouseX, mouseY, debugRect)) {
                var cornerNum = whichCornerHovered(mouseX, mouseY, debugRect);
                if (cornerNum != null) {
                    return startResizing(mouseX, mouseY, cornerNum);
                }

                return startDragging(mouseX, mouseY, debugRect);
            }
            if (!(mouse.modifiers & Qt.ControlModifier)) {
                return mouse.accepted = false;
            }
            d.isDrawing = true;
            d.x_ = mouseX;
            d.y_ = mouseY;
        }
        onPositionChanged: {
            // ресайз квадрата за уголки
            if (d.resizingCorner > -1) {
                resizeRect(mouseX, mouseY, d.resizingCorner);
                return;
            }

            // таскание элемента
            if (d.draggingElement) {
                updateElement(mouseX, mouseY, d.draggingElement);
                updateElement(mouseX, mouseY, debugInfo); // хардкод :p
                return;
            }

            // рисование элемента
            if (d.isDrawing) {
                d.w = d.getWidth(d.x_, mouseX)
                d.h = d.getHeight(d.y_, mouseY)
                debugRect.x = Math.min(mouseX, d.x_)
                debugRect.y = Math.min(mouseY, d.y_)
                debugRect.width = d.w || 1
                debugRect.height = d.h || 1

                debugInfo.x = mouseX;
                debugInfo.y = mouseY;
                d.updateDebugInfo();
                return;
            }

            // по ховеру показать уголки
            if (insideObject(mouseX, mouseY, debugRect)) {
                corner.show(whichCornerHovered(mouseX, mouseY));
            }
        }
        onReleased: {
            if (d.resizingCorner > -1) return stopResizing();
            if (d.draggingElement) return stopDragging();
            if (d.isDrawing) return stopDrawing();
        }
        onWheel: {
            if (wheel.modifiers & Qt.ControlModifier) {
                if (wheel.angleDelta.y > 0) {
                    //Ui.dpimult += 0.1;
                    ideal.width *= 1.1;
                    ideal.height *= 1.1;
                    rootAppWindow.width *= 1.1;
                    rootAppWindow.height *= 1.1;
                    debugRect.width *= 1.1;
                    debugRect.height *= 1.1;
                    debugRect.x *= 1.1;
                    debugRect.y *= 1.1;
                } else {
                   // Ui.dpimult -= 0.1;
                    ideal.width /= 1.1;
                    ideal.height /= 1.1;
                    rootAppWindow.width /= 1.1;
                    rootAppWindow.height /= 1.1;
                    debugRect.width /= 1.1;
                    debugRect.height /= 1.1;
                    debugRect.x /= 1.1;
                    debugRect.y /= 1.1;
                }
            }
        }
    }
    Rectangle {
        id: debugRect
        border.color: Qt.lighter(color)
        border.width: 1
        color: 'red'
        opacity: 0.3
    }
    Rectangle {
        id: corner
        color: 'transparent'
        border.color: 'white'
        border.width: 1
        visible: false
        readonly property int _UPPER_LEFT: 0
        readonly property int _UPPER_RIGHT: 1
        readonly property int _BOTTOM_LEFT: 2
        readonly property int _BOTTOM_RIGHT: 3
        property var positions: [
            {x: debugRect.x, y: debugRect.y},
            {x: debugRect.x + corner.width * 3, y: debugRect.y},
            {x: debugRect.x, y: debugRect.y + corner.height * 3},
            {x: debugRect.x + corner.width * 3, y: debugRect.y + corner.height * 3}
        ]
        function show(i) {
            if (i == null || i === -1) return;
            var pos = positions[i];
            if (corner.x !== pos.x) corner.x = pos.x;
            if (corner.y !== pos.y) corner.y = pos.y;
            if (!corner.visible) corner.visible = true;
        }
        function updateSize() {
            corner.width = debugRect.width / 4;
            corner.height = debugRect.height / 4;
        }
    }
    Text {
        id: debugInfo
        color: 'black'
        styleColor: "#90ffffff"
        style: Text.Outline
    }
}
