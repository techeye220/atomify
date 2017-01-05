import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import Atomify 1.0

Pane {
    id: root

    signal simulationClicked(var script)

    property var tagModel: []
    property var tagMap: {
        "water": "Water",
                "silica": "Silica",
                "other": "Other"
    }

    property Item screenshotObject
    property string currentScript

    property string serverUrl: "http://95.85.59.61:1338/parse"

    Component.onCompleted: {
        refresh()
    }
    padding: 32

    function upload() {
        var name = nameField.text
        var description = descriptionField.text
        if(!screenshotObject) {
            console.warn("screenshotObject must be set to allow uploads")
            return
        }

        screenshotObject.grabToImage(function(result) {
            console.log("Grabbed screenshot")
            parseFileUploader.uploadGrabbedImage(result, function(uploadResult) {
                console.log("Got data", uploadResult)
                var uploadData = JSON.parse(uploadResult);

                var status
                var req = new XMLHttpRequest;
                req.open("POST", serverUrl + "/classes/Simulation");
                req.setRequestHeader("X-Parse-Application-Id", "atomify");
                var data = {
                    name: name,
                    description: description,
                    script: currentScript,
                    image: {
                        "name": uploadData.name,
                        __type: "File"
                    }
                }

                req.onreadystatechange = function() {
                    status = req.readyState;
                    if (status === XMLHttpRequest.DONE) {
                        console.log(req.responseText);
                        refresh()
                    }
                }
                console.log("Sending", JSON.stringify(data))
                req.send(JSON.stringify(data))
            })
        })
    }

    function refresh() {
        var status
        var wasLoading
        var req = new XMLHttpRequest;
        req.open("GET", serverUrl + "/classes/Simulation");
        req.setRequestHeader("X-Parse-Application-Id", "atomify");
        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                var objectArray = JSON.parse(req.responseText);
                if (objectArray.errors !== undefined)
                    console.log("Error fetching tweets: " + objectArray.errors[0].message)
                else {
                    var newTagModel = []
                    for(var i in tagMap) {
                        newTagModel.push({
                                             "tag": i,
                                             "name": tagMap[i],
                                             "simulations": []
                                         })
                    }
                    for(var i in objectArray.results) {
                        var simulation = objectArray.results[i]
                        var tagFound = false
                        for(var j in newTagModel) {
                            var tag = newTagModel[j]
                            for(var k in simulation.tags) {
                                var simulationTag = simulation.tags[k]
                                if(tag.tag === simulationTag) {
                                    tag.simulations.push(simulation)
                                    tagFound = true
                                }
                            }
                        }
                        if(!tagFound) {
                            for(var j in newTagModel) {
                                var tag = newTagModel[j]
                                if(tag.tag === "other") {
                                    tag.simulations.push(simulation)
                                }
                            }
                        }
                    }
                    tagModel = newTagModel
                }
                if (wasLoading == true) {
                    console.log("Is loaded")
                }
            }
            wasLoading = (status === XMLHttpRequest.LOADING);
        }
        req.send();
    }

    function getFiles(objectId) {
        console.log("Get files for", objectId)
        var status
        var wasLoading
        var req = new XMLHttpRequest;
        var urlData = 'where={"$relatedTo":{"object":{"__type":"Pointer","className":"Simulation","objectId":"' + objectId + '"},"key":"files"}}'
        req.open("GET", serverUrl + "/classes/SimulationFile?" + urlData);
        req.setRequestHeader("X-Parse-Application-Id", "atomify");
        req.onreadystatechange = function() {
            status = req.readyState;
            if (status === XMLHttpRequest.DONE) {
                //                console.log("Response: ", req.responseText)
                var objectArray = JSON.parse(req.responseText);
                if (objectArray.errors !== undefined)
                    console.log("Error fetching tweets: " + objectArray.errors[0].message)
                else {
                    for(var i in objectArray.results) {
                        var fileObject = objectArray.results[i]
                        var file = fileObject.file
                        console.log("Object ID", objectId, file.url)
                    }
                }
                if (wasLoading == true) {
                    console.log("Is loaded")
                }
            }
            wasLoading = (status === XMLHttpRequest.LOADING);
        }
        req.send();

    }
    Flickable {
        anchors.fill: parent
        contentHeight: content.height
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
            }

            spacing: 24

            Label {
                text: "Examples"
                font.pixelSize: 32
            }

            Repeater {
                model: Object.keys(tagModel).length

                Column {
                    id: tagView
                    property var tagData: tagModel[index]

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    spacing: 24

                    Label {
                        text: tagData.name
                    }

                    Flow {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        spacing: 24

                        Repeater {
                            id: simulationsView
                            anchors {
                                top: parent.top
                                right: parent.right
                                left: parent.left
                                bottom: parent.bottom
                            }
                            clip: true
                            property var listModel: tagData.simulations
                            model: simulationsView.listModel.length

                            Rectangle {
                                property var modelData: simulationsView.listModel[index]

                                width: 240
                                height: column.height

                                color: Material.color(Material.Grey, Material.Shade900)

                                Column {
                                    id: column
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                    }

                                    spacing: 8

                                    Image {
                                        id: exampleImage
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }

                                        height: width
                                        fillMode: Image.PreserveAspectCrop
                                        source: modelData.image ? modelData.image.url : ""
                                        smooth: true
                                        antialiasing: true
                                        mipmap: true
                                    }

                                    Item {
                                        height: 8
                                        width: 1
                                    }

                                    Label {
                                        id: exampleName
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            margins: 16
                                        }

                                        font.weight: Font.Bold
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                        text: modelData.name
                                    }

                                    Label {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            margins: 16
                                        }
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                        text: modelData.description ? modelData.description : "No description"
                                    }

                                    Item {
                                        height: 16
                                        width: 1
                                    }

                                    //                    Label {
                                    //                        anchors {
                                    //                            left: parent.left
                                    //                            right: parent.right
                                    //                        }
                                    //                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    //                        text: "Tags: " + (modelData.tags ? JSON.stringify(modelData.tags) : "No tags")
                                    //                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("TODO: Download files")
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }

    }

    //    Column {
    //        id: uploadColumn
    //        anchors {
    //            bottom: parent.bottom
    //            left: parent.left
    //            right: parent.right
    //        }

    //        Label {
    //            text: "Upload your current simulation"
    //        }

    //        Label {
    //            text: "Name"
    //        }

    //        TextField {
    //            id: nameField
    //            text: "Name"
    //        }

    //        Label {
    //            text: "Description"
    //        }

    //        TextField {
    //            id: descriptionField
    //            text: "Description"
    //        }

    //        Button {
    //            id: uploadButton
    //            text: "Upload"

    //            onClicked: {
    //                upload()
    //            }
    //        }
    //    }

    //    ParseFileUploader {
    //        id: parseFileUploader
    //    }
}