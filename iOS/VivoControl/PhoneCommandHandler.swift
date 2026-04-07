import Foundation
import Shared

/// Receives a CommandEnvelope from the Watch, calls the backend, then
/// broadcasts the new state via updateApplicationContext so the Watch
/// updates without polling.
@MainActor
struct PhoneCommandHandler {
    let viewModel: PropertyViewModel

    func handle(_ envelope: CommandEnvelope) {
        viewModel.record(envelope)

        switch envelope.command {
        case .openGate(_, let gateID):
            // In production: backend.openGate(propertyID, gateID) -> await result
            viewModel.setGate(gateID, to: .open)
        case .closeGate(_, let gateID):
            viewModel.setGate(gateID, to: .closed)
        case .unlockDoor(_, let doorID):
            viewModel.setDoor(doorID, locked: false)
        case .lockDoor(_, let doorID):
            viewModel.setDoor(doorID, locked: true)
        case .requestSnapshot:
            // In production: backend.fetchSnapshot(...) and push the URL via context
            break
        }

        broadcastState()
    }

    private func broadcastState() {
        let context: [String: Any] = [
            "property_name": viewModel.property.name,
            "gate_state": viewModel.property.gates.first?.state.rawValue ?? "unknown",
            "door_locked": viewModel.property.doors.first?.locked ?? true,
        ]
        try? WatchConnectivityClient.shared.updateContext(context)
    }
}
