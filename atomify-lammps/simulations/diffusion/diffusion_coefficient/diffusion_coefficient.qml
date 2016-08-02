import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import Atomify 1.0
import "qrc:/core"
import "qrc:/mobile/dashboard/controls"

Simulation {
    name: "Diffusion coefficient"
    description: "<p>The diffusion coefficient can be measured as the slope of the mean square displacement r^2(t) (MSD).</p>
<p>The MSD is defined as the average distance atoms have to their original position a time t earlier.</p>
<p><b>Things to look for</b></p>
<p>In the beginning of the MSD measurement, on a short time scale, the atoms move more or less in a straight line giving rise to the non-linear ballistic regime.
The system then goes over to the linear regime where we can read out the diffusion coefficient. </p>"
    initialCameraPosition: Qt.vector3d(0,0,20)
    controllers: [
        MeanSquareDisplacement {},
        Thermometer {},
        Thermostat {}
    ]
}
