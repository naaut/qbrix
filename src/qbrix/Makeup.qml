import QtQuick 2.4

/*!
 \brief Помощник верстальщика
    ctrl + mousePress    рисовать измеряющий квадратик
    квадратик можно передвигать и растягивать (изменять размеры)
 */

Item {
    id: i

    property alias idealImage: ideal.source
    property alias idealOpacity: ideal.opacity
    property alias componentLoader: componentLoader

    property var rootAppWindow: parent
    property real mScale: 1.0
    property bool ctrl: false
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

    /*!
     \brief Меняет местами Z у componentLoader'а и картинки ideal
     */
    function changeZ() {
        if (ideal.z === 2) {
            componentLoader.z = 2;
            ideal.z = 1;
        } else {
            componentLoader.z = 1;
            ideal.z = 2;
        }
    }

    /*!
     \brief Меняет формат отображения пикселей на % и обратно
     */
    function changeMode() {
        mode = next(modes, mode);
        d.updateDebugInfo();
    }

    /*!
     \brief Удаляет debugRect
     */
    function clearDebugRect() {
        debugRect.width = debugRect.height = 0;
        debugInfo.text = "";
        corner.visible = false;
    }

    /*!
     \brief Удаляет картинку ideal
     */
    function clearIdeal() {
        ideal.source = "";
    }

    /*!
     \brief Сброс масштаба на 1:1
     */
    function resetScale() {
        mScale = 1;
        corner.visible = false;
    }

    /*!
     \brief  Устанавливаем componentLoader и картинку ideal по центру
    */
    function setAtCenter() {
        componentLoader.x = i.width/2 - componentLoader.width/2;
        componentLoader.y = i.height/2 - componentLoader.height/2;
        ideal.x = i.width/2 - ideal.width/2;
        ideal.y = i.height/2 - ideal.height/2;
       // debugRect.x = i.width/2 - debugRect.width/2;
       // debugRect.y = i.height/2 - debugRect.height/2;
       // corner.visible = false;
       // corner.updateSize();
       // updateElement(debugRect.x , debugRect.y - debugInfo.height, debugInfo);
    }

    Loader{
        id: componentLoader
        z:1

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
        z: 2

        opacity: 0.5
        playing: false

        onSourceChanged: {
            ideal.x = i.width/2 - ideal.width/2;
            ideal.y = i.height/2 - ideal.height/2;
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent

            onClicked: {
                ideal.playing = ideal.playing ? false : true;
            }
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
            debugInfo.text = 'w:' + getSize(d.w) +' h:' + getSize(d.h) + ' (' + nameMode() + ')';
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
            debugRect.width += offsetX/mScale;
            debugRect.height += offsetY/mScale;
            if (debugRect.width > 2) debugRect.x -= offsetX;
            if (debugRect.height > 2)  debugRect.y -= offsetY;
            break;
        case corner._UPPER_RIGHT:
            offsetX = debugRect.x - ((mouseX + (d.resizingOffsetX)) - debugRect.width * mScale);
            offsetY = debugRect.y - (mouseY - d.resizingOffsetY);
            debugRect.width -= offsetX/mScale;
            debugRect.height += offsetY/mScale;
            if (debugRect.height > 2)  debugRect.y -= offsetY;
            break;
        case corner._BOTTOM_LEFT:
            offsetX = debugRect.x - (mouseX - d.resizingOffsetX);
            offsetY = debugRect.y - ((mouseY + d.resizingOffsetY) - debugRect.height * mScale);            
            debugRect.width += offsetX/mScale;
            debugRect.height -= offsetY/mScale;
            if (debugRect.width > 2) debugRect.x -= offsetX;
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
        z: 3

        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true

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
            mainMouse.cursorShape = Qt.CrossCursor;
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
                d.w = d.getWidth(d.x_, mouseX)/mScale ;
                d.h = d.getHeight(d.y_, mouseY)/mScale ;
                debugRect.x = Math.min(mouseX, d.x_);
                debugRect.y = Math.min(mouseY, d.y_);
                debugRect.width = d.w || 1;
                debugRect.height = d.h || 1;
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
            mainMouse.cursorShape = Qt.ArrowCursor;
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
        z: 4

        border.color: Qt.lighter(color)
        border.width: 1
        color: 'red'
        opacity: 0.3
        transform: Scale { xScale: mScale;  yScale: mScale}
    }
    Rectangle {
        id: corner
        z: 5

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
        z: 6

        color: 'black'
        styleColor: "#90ffffff"
        style: Text.Outline
    }

    Text {
        id: scale
        z: 6

        color: 'black'
        styleColor: "#90ffffff"
        style: Text.Outline

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        text: "scale: " + mScale.toFixed(1);
    }
}
