import QtQuick 2.0
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Controls 2.5

Item {
    id: window
    property int heading: 90
    property int kitHdg: 90
    property int orbitRadius: 0
    property double xPos: 0
    property double yPos: 0
    property int tgtCount: 0
    property variant targetList: []
    property var kitList: []
    property int kitStartNr: 1234
    property int curTarget: -1
    property int traceLength: 60  // In seconds    

    Plugin {
        id: mapPlugin
        name: "esri"
//        name: "osm"
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
//        PluginParameter { name: "esri.mapping.cache.directory"; value: "C:/WorkArea/Programs/Qt/MapViewer/EsriImageCache" }
        PluginParameter { name: "esri.mapping.cache.directory"; value: "/home/user/EsriImageCache" }
    }    


    // Method to set current target to be followed by kit
    function changeTarget(tgt) {
//        targetList[tgt - 1].color = "#e41e25"
        targetList[tgt - 1].makeVisible = true

        // for first target selection
        if(curTarget !== -1) {
            targetList[curTarget].makeVisible = true
        }
        curTarget = tgt - 1

    }


    function midPoint(coord1, coord2) {

        var delta = coord2.longitude - coord1.longitude
        delta = delta * Math.PI / 180.0

        var rLat1 = coord1.latitude * Math.PI / 180.0
        var rLat2 = coord2.latitude * Math.PI / 180.0
        var rLon1 = coord1.longitude * Math.PI / 180.0

        var Bx = Math.cos(rLat2) * Math.cos(delta)
        var By = Math.cos(rLat2) * Math.sin(delta)
        var lat3 = Math.atan2(Math.sin(rLat1) + Math.sin(rLat2),
                              Math.sqrt( (Math.cos(rLat1) + Bx) * (Math.cos(rLat1) + Bx) + By * By))
        var lon3 = rLon1 + Math.atan2(By, Math.cos(rLat1) + Bx)

        return QtPositioning.coordinate(lat3 * 180.0 / Math.PI, lon3 * 180.0 / Math.PI)
    }


    function addNewKit() {
        var component = Qt.createComponent("qrc:///qml/kit.qml")
        if( component.status !== Component.Ready )
        {
            if( component.status === Component.Error )
                console.debug("Error:"+ component.errorString() );
            return; // or maybe throw
        }

        kitStartNr += 1
        var kit = component.createObject(window,
                               { kitName: 'KIT-' + kitStartNr,
                                 heading: Math.floor(Math.random() * 360),
                                 coordinate: QtPositioning.coordinate(map.toCoordinate(Qt.point(xPos, yPos)).latitude,
                                                                      map.toCoordinate(Qt.point(xPos, yPos)).longitude)})

        kitList.push(kit)
        map.addMapItemGroup(kit)
    }

    function addNewTarget() {
//        var tgtId = "TGT-" + tgtCount;
        tgtCount += 1;

        var comp;
        if((tgtCount % 3) == 1) {
            comp = Qt.createComponent("qrc:///qml/target.qml")
        } else if((tgtCount % 3) == 2) {
            comp = Qt.createComponent("qrc:///qml/target2.qml")
        }
        else {
            comp = Qt.createComponent("qrc:///qml/target3.qml")
        }

        if( comp.status !== Component.Ready )
        {
            if( comp.status === Component.Error )
                console.debug("Error:"+ comp.errorString() );
            return; // or maybe throw
        }

        // Create object dynamically
        var target = comp.createObject(window,
                                       { text: tgtCount,
                                         coordinate: QtPositioning.coordinate(map.toCoordinate(Qt.point(xPos, yPos)).latitude,
                                                                              map.toCoordinate(Qt.point(xPos, yPos)).longitude)})
        targetList.push(target)
        target.targetChanged.connect(changeTarget)
        map.addMapItemGroup(target)
    }        

    function computeKitNewPosition() {
        for(var i = 0; i < kitList.length; ++i) {

//            kitList[i].coordinate.latitude += 0.0001


            var rLat = kitList[i].coordinate.latitude * Math.PI / 180.0
            var rLon = kitList[i].coordinate.longitude * Math.PI / 180.0

            var earthRadius = 6371 * 1000; // In meters
            var speed = 10//Math.floor(Math.random() * 30); // m/s
            var time = 1; // second
            var distance = speed * time;
            var d = distance / earthRadius;

            kitList[i].heading += 1

            var newLat = Math.asin( Math.sin(rLat) * Math.cos(d) + Math.cos(rLat) * Math.sin(d) * Math.cos(kitList[i].heading * Math.PI / 180.0));
            var newLon = rLon + Math.atan2(Math.sin(kitList[i].heading * Math.PI / 180.0) * Math.sin(d) * Math.cos(rLat),
                                           Math.cos(d) - Math.sin(rLat) * Math.sin(newLat));

            kitList[i].coordinate.latitude = newLat * 180.0 / Math.PI;
            kitList[i].coordinate.longitude =  newLon * 180.0 / Math.PI;

            // Add a trace
            if(kitList[i].tracePath.pathLength() < traceLength ) {
                kitList[i].tracePath.addCoordinate(kitList[i].coordinate)
            } else {
                kitList[i].tracePath.removeCoordinate(0)
                kitList[i].tracePath.addCoordinate(kitList[i].coordinate)
            }

//            var path = kitToTarget.path;

//            if(targetList.length > 0 && curTarget != -1) {
//                path[1].latitude = tgtCoordinate.latitude;
//                path[1].longitude = tgtCoordinate.longitude;
//                path[0].latitude = kit1234.coordinate.latitude;
//                path[0].longitude = kit1234.coordinate.longitude;
//            }

//            kitToTarget.path = path;
        }

    }

    function computeNextPosition() {

        computeKitNewPosition()
        var lat = kit1234.coordinate.latitude;
        var lon = kit1234.coordinate.longitude;

        var earthRadius = 6371 * 1000; // In meters
        var speed = 10; // m/s
        var time = 1; // second
        var distance = speed * time;
        var d = distance / earthRadius;
        var rLat = lat * Math.PI / 180.0;
        var rLon = lon * Math.PI / 180.0;

        var tgtCoordinate;
        var distToTarget

        if( targetList.length > 0 && curTarget != -1) {
            tgtCoordinate = targetList[curTarget].coordinate
            heading = kit1234.coordinate.azimuthTo(tgtCoordinate)
            distToTarget = kit1234.coordinate.distanceTo(tgtCoordinate)
            var dst = ''
            if( distToTarget > 1000 ) {
                dst = (distToTarget / 1000)
                dst = dst.toFixed(2) + ' km'
            }
            else if (distToTarget < 1000 && distToTarget > 250) {
                dst = distToTarget.toFixed(0) + ' m'
            }
            else {
                dst = ''
            }

            distText.text = dst
            distText.coordinate = midPoint(kit1234.coordinate, tgtCoordinate)
            console.log("DTT: ", distToTarget, distText.text)
            if(distToTarget < 250) {
                targetList[curTarget].makeVisible = !targetList[curTarget].makeVisible
            }

            if( distToTarget <= 10 ) {
                // look for the next target
                if(targetList.length - 1 >= curTarget) {
                    targetList[curTarget].makeVisible = true
                    targetList[curTarget].color = "orange"
                    if( curTarget < targetList.length - 1)
                        curTarget += 1
                }
            }
        }
        else {
            orbitRadius += 1
            if(orbitRadius >= 5) {
                heading += 5;
                orbitRadius = 0;
            }
        }

        kit1234.rotation = heading
//        kitId.rotation = heading

        var newLat = Math.asin( Math.sin(rLat) * Math.cos(d) + Math.cos(rLat) * Math.sin(d) * Math.cos(heading * Math.PI / 180.0));
        var newLon = rLon + Math.atan2(Math.sin(heading * Math.PI / 180.0) * Math.sin(d) * Math.cos(rLat),
                                       Math.cos(d) - Math.sin(rLat) * Math.sin(newLat));

        if(trace.pathLength() < traceLength ) {
            trace.addCoordinate(kit1234.coordinate)
        } else {
            trace.removeCoordinate(0)
            trace.addCoordinate(kit1234.coordinate)
        }

        kit1234.coordinate.latitude = newLat * 180.0 / Math.PI;
        kit1234.coordinate.longitude = newLon * 180.0 / Math.PI;

        var path = kitToTarget.path;

        if(targetList.length > 0 && curTarget != -1) {
            path[1].latitude = tgtCoordinate.latitude;
            path[1].longitude = tgtCoordinate.longitude;
            path[0].latitude = kit1234.coordinate.latitude;
            path[0].longitude = kit1234.coordinate.longitude;
        }

        kitToTarget.path = path;        
    }

    function setTimeout(callback, delay) {
        if(timer.running) {
            console.error("Nested call not supported");
            return;
        }
        timer.callback = callback;
        timer.interval = delay + 1;
        timer.running = true;
        timer.repeat = true;        
    }


    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(24.2217465,55.7795257)
        zoomLevel: 14        
//        copyrightsVisible: false
        activeMapType: supportedMapTypes[1]
//        activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

        MapQuickItem {
            id: kit1234
            z: map.z + 3
            coordinate {
                latitude: 24.2217465
                longitude: 55.7795257
            }
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Item {
                id: aeroplace
                anchors.centerIn: parent
                z: map.z + 3
                Rectangle {
                    id: body
                    anchors.centerIn: parent
                    width: 6; height: 24; radius: 15
                    color: "brown"
                    border.color: Qt.lighter(color)
                    border.width: 1
                    z: 3
                    Rectangle {
                        x: -8; y:6
                        width: 22; height: 3
                        color: "brown"
                        border.color: Qt.lighter(color)
                        border.width: 1
                    }

                    Rectangle {
                        x: -3; y: 21
                        width: 12; height: 3
                        color: "brown"
                        border.color: Qt.lighter(color)
                        border.width: 1
                    }
                }
            }

        }

//        MapQuickItem {
//            id: kit1234
////            sourceItem: Rectangle { width: 14; height: 14; color: "#e41e25"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
//            sourceItem: Rectangle { width: 16; height: 16; color: "#7fff00"; border.width: 2; border.color: "black"; smooth: true; radius: 8 }
//            coordinate {
//                latitude: 24.2217465
//                longitude: 55.7795257
//            }
//            opacity: 1.0
//            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
//        }

        MapQuickItem {
            id: kitId
            sourceItem: Text{
                text: "KIT-1234"
                color:"#242424"
                font.bold: true
                styleColor: "#ECECEC"
                style: Text.Outline                
            }            
            coordinate: kit1234.coordinate
            //anchorPoint: Qt.point(-kit1234.sourceItem.width * 0.5,kit1234.sourceItem.height * 2.5)
            anchorPoint: Qt.point(kit1234.width, kit1234.sourceItem.y + 40)
        }                

        MapPolyline {
            id: trace
            antialiasing: true
            z: map.z + 1
            line.width: 5
            line.color: 'lightgray'            
        }


        Timer {
            id: timer
            running:  false
            repeat: false
            property var callback
            onTriggered: callback()
        }

        MapPolyline {
            id: kitToTarget
            line.width: 1
            line.color: 'yellow'
            antialiasing: true
            z: map.z + 1
            path: [
                { latitude: 0, longitude: 0 },
                { latitude: 0, longitude: 0 }
            ]
        }

        MapQuickItem {
            id: distText
            property string text: ''
            z: map.z + 2
            sourceItem: Label {
                id: name
                text: distText.text
                font.bold: false
                font.pixelSize: 14
                color: "lime"
//                styleColor: "#ECECEC"
//                style: Text.Outline
            }
        }

        Component.onCompleted: {            
            setTimeout(computeNextPosition, 500)
        }

        MouseArea {
            id: area
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true
            onClicked: {

                var isTargetClicked = -1
                if(mouse.button === Qt.RightButton) {
                    for(var i = 0; i < targetList.length; ++i) {
                        if(targetList[i].track === true) {
                            isTargetClicked = i
                            console.log("Follow target ", i+1)
                            targetList[i].track = false
                        }
                    }
                    console.log('latitude = '+ (map.toCoordinate(Qt.point(mouse.x,mouse.y)).latitude),
                                 'longitude = '+ (map.toCoordinate(Qt.point(mouse.x,mouse.y)).longitude));
                    xPos = mouse.x
                    yPos = mouse.y
                    if( isTargetClicked === -1 )
                        contextMenu.popup()
                    }
            }

            Menu {
                id: contextMenu
                Action {
                    id: addTarget
                    text: qsTr("Add Target")
                    onTriggered: addNewTarget()
                }
                Action {
                    id: addKit
                    text: "Add Kit"
                    onTriggered: addNewKit()
                }
            }
        }
    }


}
