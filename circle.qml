import QtQuick 2.0
import QtLocation 5.3
import QtPositioning 5.3


MapCircle {
    radius: 50
    color: "darkRed"
    border.color: "#190a33"
    border.width: 2
    smooth: true
    opacity: 0.25
    center: QtPositioning.coordinate(24.2644987, 55.6356686)
}

