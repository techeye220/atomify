#ifndef LAMMPSCONTROLLER_H
#define LAMMPSCONTROLLER_H
#include <mpi.h>
#include "lammps/lammps.h"
#include "lammps/compute.h"
#include "lammpsoutput.h"
#include "CPcompute.h"
#include <memory>
#include <QVector>
#include <QString>
#include <QMap>
using namespace LAMMPS_NS;
class MyWorker;
class LAMMPSController
{
private:
    struct State {
        bool paused = false;
        bool runCommandActive = false;
        bool preRunNeeded = true;
        int  simulationSpeed = 1;
        unsigned int runCommandStart = 0;
        unsigned int runCommandEnd = 0;
    };

    State m_state;
    QVector<QString> m_commands;
    QMap<QString, CPCompute*> m_computes;
    LAMMPS *m_lammps = NULL;
    MyWorker *m_worker = NULL;

    void processComputes();
    void executeActiveRunCommand();
    int findComputeId(QString identifier);
    bool computeExists(QString identifier);
    int findFixId(QString identifier);
    bool fixExists(QString identifier);
    LAMMPS_NS::Compute *findCompute(QString identifier);
    LAMMPS_NS::Fix *findFix(QString identifier);

public:
    LammpsOutput output;

    LAMMPSController();
    ~LAMMPSController();

    // Getters/setters
    LAMMPS *lammps() const;
    void setLammps(LAMMPS *lammps);
    void setWorker(MyWorker *worker);
    int  simulationSpeed() const;
    void setSimulationSpeed(int simulationSpeed);
    QMap<QString, CPCompute *> computes() const;
    void setComputes(const QMap<QString, CPCompute *> &computes);
    bool getPaused() const;
    void setPaused(bool value);
    double simulationTime();
    int numberOfAtoms() const;
    int numberOfAtomTypes() const;
    QVector3D systemSize() const;

    // Actions
    void executeCommandInLAMMPS(QString command);
    void processCommand(QString command);
    void loadScriptFromFile(QString filename);
    void runScript(QString script);
    void reset();
    void tick();
};

#endif // LAMMPSCONTROLLER_H