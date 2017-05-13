import QtQuick 2.5
import "qrc:/core"

Simulation {
    initialCameraPosition: Qt.vector3d(0,0,20)
    name: "Flow poiseuille"
    description: "A sphere is pushed into a two dimensional solid."
    longDescription: "Here we can see how the solid breaks up from the " +
                     "incoming sphere."
}
