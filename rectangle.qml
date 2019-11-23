import QtQuick 2.0
import QtLocation 5.3


MapQuickItem {
    id: poiTheQtComapny
//    sourceItem: Rectangle { width: 14; height: 14; color: "red"; border.width: 2; border.color: "white"; smooth: true;  }
    sourceItem: Rectangle { width: 14; height: 14; color: "#67c111"; border.width: 2; border.color: Qt.lighter(color); smooth: true;  }
    opacity: 1.0
    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)

    MouseArea {
        anchors.fill: parent
        drag.target: poiTheQtComapny
        onClicked: {
            console.log("Target Clicked")

        }
    }
}




