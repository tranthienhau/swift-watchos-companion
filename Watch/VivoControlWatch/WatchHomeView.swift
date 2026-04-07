import Shared
import SwiftUI

struct WatchHomeView: View {
    @ObservedObject var state: WatchAppState

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(state.propertyName)
                    .font(.headline)

                Button {
                    sendGateCommand(open: state.gateState != .open)
                } label: {
                    Label(
                        state.gateState == .open ? "Close Gate" : "Open Gate",
                        systemImage: state.gateState == .open ? "xmark.circle.fill" : "arrow.up.circle.fill"
                    )
                }
                .tint(state.gateState == .open ? .red : .green)

                Button {
                    sendDoorCommand(lock: !state.doorLocked)
                } label: {
                    Label(
                        state.doorLocked ? "Unlock Door" : "Lock Door",
                        systemImage: state.doorLocked ? "lock.open.fill" : "lock.fill"
                    )
                }
                .tint(.blue)
            }
            .padding()
        }
    }

    private func sendGateCommand(open: Bool) {
        let command: WatchCommand = open
            ? .openGate(propertyID: state.propertyID, gateID: state.gateID)
            : .closeGate(propertyID: state.propertyID, gateID: state.gateID)
        let envelope = CommandEnvelope(command: command)
        try? WatchConnectivityClient.shared.send(envelope)
    }

    private func sendDoorCommand(lock: Bool) {
        let command: WatchCommand = lock
            ? .lockDoor(propertyID: state.propertyID, doorID: state.doorID)
            : .unlockDoor(propertyID: state.propertyID, doorID: state.doorID)
        let envelope = CommandEnvelope(command: command)
        try? WatchConnectivityClient.shared.send(envelope)
    }
}
