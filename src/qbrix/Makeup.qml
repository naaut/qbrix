import QtQuick 2.4

/*!
 \brief Помощник верстальщика
    ctrl + mousePress    рисовать измеряющий квадратик
    ctrl + P             изменить режим измерения квадратиком (пиксели/проценты)
    ctrp + Q             удалить измеряющий квадратик
    ctrl + W             установить зум в 1
    ctrl + E             удалить картинку
    ctrl + R             установить зум в 1, отцентрировать квадрат, компонент и картинку
    ctrl + "-"           сбросить зум, удалить картинку
    ctrl + wheel         зум
    ctrl + upArrow       переключиться на дизайн
    ctrl + downArrow     переключиться на верстку

    квадратик можно передвигать и растягивать (изменять размеры)
 */

Item {
    id: i

    property var rootAppWindow : parent;
    property real mScale: 1.0;
    property var modes: ({
        PX: 0,
        PP: 1
    });
    property int mode: modes.PX
    property var px2pph: {
        return function(px) {
            if (rootAppWindow)
                return px / rootAppWindow.height * 100;
            else
                return px;
        }
    }

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
            return px2pph(v).toFixed(2);
        }
    }

    property alias idealImage: ideal.source
    property alias componentLoader: componentLoader
    property bool ctrl: false
    Component.onCompleted: {
        forceActiveFocus();
    }

    Keys.onUpPressed: ideal.opacity += 0.5
    Keys.onDownPressed: ideal.opacity -= 0.5
    Keys.onLeftPressed: {
        debugRect.x = debugRect.y = debugRect.width = debugRect.height = 0;
    }

    Keys.onPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            mainMouse.cursorShape = Qt.CrossCursor;
            switch (event.key) {
            //"Ctrl" + "-"
            case 45:
                //Clear All
                debugRect.width = 0;
                debugRect.height = 0;
                debugInfo.text = "";
                ideal.source = "";
                mScale = 1;
                break;
            //"Ctrl" + "P"
            case 80:
                // Set mode to %
                mode = next(modes, mode);
                d.updateDebugInfo();
                break;
            //"Ctrl" + "E"
            case 69:
                // Clear ideal
                ideal.source = "";
                break;
            //"Ctrl" + "Q"
            case 81:
                // clear debug Rectangle
                debugRect.width = 0;
                debugRect.height = 0;  
                debugInfo.text = "";
                ideal.source = ""
                corner.visible = false;
                break;
            //"Ctrl" + "W"
            case 87:
                //reset Scale
                mScale = 1;
                corner.visible = false;
                break;
            //"Ctrl" + "R"
            case 82:
                // Reset Scale and set at center
                mScale = 1;
                componentLoader.x = i.width/2 - componentLoader.width/2;
                componentLoader.y = i.height/2 - componentLoader.height/2;
                ideal.x = i.width/2 - ideal.width/2;
                ideal.y = i.height/2 - ideal.height/2;
                debugRect.x = i.width/2 - debugRect.width/2;
                debugRect.y = i.height/2 - debugRect.height/2;
                corner.visible = false;
                corner.updateSize();
                updateElement(debugRect.x , debugRect.y - debugInfo.height, debugInfo);
                break;
            }
        }
    }
    Keys.onReleased: {
        mainMouse.cursorShape = Qt.ArrowCursor;
    }

    Loader{
        id: componentLoader
        MouseArea {
            anchors.fill: parent
            drag.target: parent
        }
        transform: Scale { xScale: mScale;  yScale: mScale}
        onSourceChanged: {
            componentLoader.x = parent.width/2 - componentLoader.width/2;
            componentLoader.y = parent.height/2 - componentLoader.height/2;
        }
    }

     AnimatedImage {
        id: ideal
        opacity: 0.5

        onSourceChanged: {
            ideal.width = undefined;
            ideal.height = undefined;
            ideal.x = i.width/2 - ideal.width/2;
            ideal.y = i.height/2 - ideal.height/2;
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent
        }

        transform: Scale { xScale: mScale;  yScale: mScale}
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
        return inside(x, y, target.x, target.y, target.width * mScale, target.height * mScale);
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
            if (inside(mouseX, mouseY, c.x, c.y, corner.width * mScale, corner.height * mScale)) {
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
            debugRect.width += offsetX/mScale;
            debugRect.height += offsetY/mScale;
            break;
        case corner._UPPER_RIGHT:
            offsetX = debugRect.x - ((mouseX + (d.resizingOffsetX)) - debugRect.width * mScale);
            offsetY = debugRect.y - (mouseY - d.resizingOffsetY);
            debugRect.y -= offsetY ;
            debugRect.width -= offsetX/mScale;
            debugRect.height += offsetY/mScale;
            break;
        case corner._BOTTOM_LEFT:
            offsetX = debugRect.x - (mouseX - d.resizingOffsetX);
            offsetY = debugRect.y - ((mouseY + d.resizingOffsetY) - debugRect.height * mScale);
            debugRect.x -= offsetX;
            debugRect.width += offsetX/mScale;
            debugRect.height -= offsetY/mScale;
            break;
        case corner._BOTTOM_RIGHT:
            offsetX = debugRect.x - ((mouseX + d.resizingOffsetX) - debugRect.width * mScale);
            offsetY = debugRect.y - ((mouseY + d.resizingOffsetY) - debugRect.height * mScale);
            debugRect.width -= offsetX/mScale;
            debugRect.height -= offsetY/mScale;
            break;
        }
        if (debugRect.width <= 1) debugRect.width = 1;
        if (debugRect.height <= 1) debugRect.height = 1;
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
            d.resizingOffsetX = corner.positions[cornerPos].x + corner.width * mScale - mouseX;
            d.resizingOffsetY = mouseY - corner.positions[cornerPos].y;
            break;
        case corner._BOTTOM_LEFT:
            d.resizingOffsetX = mouseX - corner.positions[cornerPos].x;
            d.resizingOffsetY = corner.positions[cornerPos].y + corner.height * mScale - mouseY;
            break;
        case corner._BOTTOM_RIGHT:
            d.resizingOffsetX = corner.positions[cornerPos].x + corner.width * mScale - mouseX;
            d.resizingOffsetY = corner.positions[cornerPos].y + corner.height * mScale - mouseY;
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

        onContainsMouseChanged: {
            if (containsMouse && !activeFocus) forceActiveFocus();
        }        

        onPressed: {
            corner.visible = false;
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
                updateElement(debugRect.x, debugRect.y - debugInfo.height, debugInfo);
                return;
            }

            // таскание элемента
            if (d.draggingElement) {
                updateElement(mouseX, mouseY, d.draggingElement);
                updateElement(mouseX, mouseY - debugInfo.height, debugInfo); // хардкод :p
                return;
            }

            // рисование элемента
            if (d.isDrawing) {
                d.w = d.getWidth(d.x_, mouseX);
                d.h = d.getHeight(d.y_, mouseY);
                debugRect.x = Math.min(mouseX, d.x_);
                debugRect.y = Math.min(mouseY, d.y_);
                debugRect.width = d.w/mScale || 1;
                debugRect.height = d.h/mScale || 1;

                debugInfo.x = debugRect.x;
                debugInfo.y = debugRect.y - debugInfo.height;
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
                    mScale += 0.1;
                    corner.visible = false;
                    corner.updateSize();
                } else {
                    mScale -= 0.1;
                    if (mScale <= 0.11) mScale = 0.1;
                    corner.visible = false;
                    corner.updateSize();
                }
            }
            updateElement(debugRect.x, debugRect.y - debugInfo.height, debugInfo);
        }
    }
    Rectangle {
        id: debugRect
        border.color: Qt.lighter(color)
        border.width: 1
        color: 'red'
        opacity: 0.3
        transform: Scale { xScale: mScale;  yScale: mScale}
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
            {x: debugRect.x + corner.width * 3 * mScale, y: debugRect.y},
            {x: debugRect.x, y: debugRect.y + corner.height * 3 * mScale},
            {x: debugRect.x + corner.width * 3 * mScale, y: debugRect.y + corner.height * 3 * mScale}
        ]
        function show(i) {
            if (i == null || i === -1) return;
            var pos = positions[i];
            if (corner.x !== pos.x) corner.x = pos.x;
            if (corner.y !== pos.y) corner.y = pos.y;
            if (!corner.visible) corner.visible = true;
        }
        function updateSize() {
            corner.width = (debugRect.width / 4);
            corner.height = (debugRect.height / 4);
        }
        transform: Scale { xScale: mScale;  yScale: mScale}

    }
    Text {
        id: debugInfo
        color: 'black'
        styleColor: "#90ffffff"
        style: Text.Outline
    }

    Text {
        id: scale
        color: 'black'
        styleColor: "#90ffffff"
        style: Text.Outline
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: "scale: " + mScale.toFixed(1);
    }
}
