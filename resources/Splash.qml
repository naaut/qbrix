import QtQuick 2.4


Rectangle {

    id: i
    width: 360
    height: 580

    MouseArea {

        anchors.fill: parent

        onClicked: {
            anim.start();        
        }
        onDoubleClicked: {
            anim.stop(); 
        }
    }

    Component.onCompleted: {
           //anim.start()
     }

    Rectangle {
        id: mainRound 
        width: 224
        height: 224
        radius: width/2       
        opacity: 1
        color: "#afca0a"
        anchors.centerIn: parent
    }

    Rectangle {
        id: blinkRound

        width: 224
        height: 224
        radius: width/2
        color: "#afca0a"
        anchors.centerIn: parent
    }

    SequentialAnimation {

        id: anim

        loops: Animation.Infinite

        NumberAnimation {
            target: mainRound
            properties: "width, height"
            duration: 250
            easing.type: Easing.Linear
            to: 264
        }


        ParallelAnimation {

            NumberAnimation {
                target: blinkRound;
                properties: "width, height"
                easing.type: Easing.Linear
                duration: 160
                to: 325
            }

            NumberAnimation {
                target: mainRound;
                properties: "width, height"
                easing.bezierCurve:[0.42,0.419,0.71,0.684,0.84,1.01,0.81,1.29,1,1.41,1,1]
                duration: 560;
                to: 224
            }

            SequentialAnimation {

                  OpacityAnimator {
                    target: blinkRound;
                    easing.type: Easing.Linear;
                    duration: 160
                    from: 0.7
                    to: 0.2
                }

                OpacityAnimator {
                    target: blinkRound;
                    easing.type: Easing.Linear;
                    duration: 250;
                    from: 0.2
                    to: 0
                }
            }
        }

        ParallelAnimation {

            NumberAnimation {
                target: mainRound
                properties: "width, height"
                duration: 500
                easing.type: Easing.Linear
                to: 800
            }

            NumberAnimation {
                target: mainRound
                property: "opacity"
                duration: 500
                easing.type: Easing.Linear
                to: 0
            }

            NumberAnimation {
                target: i
                property: "opacity"
                duration: 500
                easing.type: Easing.Linear
                to: 0
            }
        }

        PauseAnimation {
            duration: 520
        }

        NumberAnimation {
            target: blinkRound;
            properties: "width, height"
            easing.type: Easing.OutSine;
            duration: 1;
            to: 264
        }

        NumberAnimation {
            target: mainRound;
            properties: "width, height"
            duration: 1;
            to: 224
        }

        NumberAnimation {
            target: mainRound
            property: "opacity"
            duration: 1
            easing.type: Easing.Linear
            to: 1
        }

        NumberAnimation {
            target: i
            property: "opacity"
            duration: 1
            easing.type: Easing.Linear
            to: 1
        }
    }
}
































































