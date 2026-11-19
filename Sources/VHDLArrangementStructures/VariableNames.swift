import VHDLParsing

/// The name of a variable that is defined within and below the machine object.
///
/// e.g. ``Machine.externalSignals``, ``Machine.clocks``, ``Machine.machineSignals``, ``State.signals``.
typealias MachineVariableName = VariableName

/// The name of a variable that is defined within the arrangement.
///
/// e.g. ``Arrangement.externalSignals``, ``Arrangement.signals``, ``Arrangement.clocks``.
typealias ArrangementVariableName = VariableName

/// The name of a machine instance.
typealias MachineInstanceName = VariableName
