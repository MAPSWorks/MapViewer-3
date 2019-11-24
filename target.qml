import QtQuick 2.12
import QtLocation 5.12
import QtQuick.Controls 2.5

MapItemGroup {

    id: itemGroup
    property alias text: labelText.text
    property alias coordinate:  tgtRect.coordinate
    property alias track: area.track

    property string color: "#e41e25"
//    property string color: "orange"
    property bool makeVisible: true

    signal targetChanged(string tgtName)

    MapQuickItem {
        id: tgtRect

        sourceItem: Rectangle {
            width: 18; height: 18;
            color: itemGroup.color
            border.width: 1;
            border.color: Qt.lighter(color)
            smooth: true
            visible: itemGroup.makeVisible
//            opacity: 0.7
            Rectangle {
                width: 12; height: 2
                color: "white"
                anchors.centerIn: parent
                opacity: 1
            }

            Rectangle {
                width: 2; height: 12
                color: "white"
                anchors.centerIn: parent
            }
        }
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)

        MouseArea {
            id: area
            property bool track: false
            anchors.fill: parent
            drag.target: tgtRect
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            propagateComposedEvents: true
            onClicked: {                
                if(mouse.button === Qt.RightButton) {
                    followTgt.popup()
                    track = true
                    mouse.accepted = false
                }
            }
        }

        Menu {
            id: followTgt
            Action {
                id: addTarget
                text: qsTr("Follow")
                onTriggered: {
                    targetChanged(labelText.text);
                }
            }
        }
    }

    MapQuickItem {
        sourceItem: Text {
            id: labelText
            text: ""
//            color:"#242424"
            color:"lime"
            font.bold: true
//            styleColor: "#ECECEC"
//            style: Text.Outline
        }
//        opacity: 0.7
        coordinate: tgtRect.coordinate
        anchorPoint: Qt.point(tgtRect.sourceItem.width * 0.5,tgtRect.sourceItem.height * 1.5)
    }
}
