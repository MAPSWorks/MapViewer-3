import QtQuick 2.12
import QtLocation 5.12
import QtQuick.Controls 2.5
import QtPositioning 5.12

MapItemGroup {
//    id: kit
    property string kitName: ''
    property alias coordinate: kitIcon.coordinate
    property int heading: 0
    property string kitColor: "brown"
    property alias tracePath: trace

    MapQuickItem {
        id: kitIcon
        z: map.z + 3
        rotation: heading
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        sourceItem: Item {
            anchors.centerIn: parent
            z: map.z + 3
            smooth: true
            antialiasing: true
            Rectangle {
                anchors.centerIn: parent
                width: 6; height: 24; radius: 15
                color: kitColor
                border.color: Qt.lighter(color)
                border.width: 1
                z: 3
                Rectangle {
                    x: -8; y:6
                    width: 22; height: 3
                    color: kitColor
                    border.color: Qt.lighter(color)
                    border.width: 1
                }

                Rectangle {
                    x: -3; y: 21
                    width: 12; height: 3
                    color: kitColor
                    border.color: Qt.lighter(color)
                    border.width: 1
                }
            }
        }
    }

    MapQuickItem {
        id: kitNum
        sourceItem: Text{
            text: kitName
            color:"#242424"
            font.bold: true
            font.pixelSize: 12
            styleColor: "#ECECEC"
            style: Text.Outline
        }
        coordinate: kitIcon.coordinate
        //anchorPoint: Qt.point(-kit1234.sourceItem.width * 0.5,kit1234.sourceItem.height * 2.5)
        anchorPoint: Qt.point(kitIcon.width, kitIcon.sourceItem.y + 40)
    }

    MapPolyline {
        id: trace
        antialiasing: true
        z: map.z + 1
        line.width: 5
        line.color: 'lightgray'
    }
}
