import Foundation
import Shared

/// Simulator-only demo script. When the app is launched with DEMO_AUTORUN=1
/// in its environment (e.g. `SIMCTL_CHILD_DEMO_AUTORUN=1 xcrun simctl launch ...`)
/// it exercises the full Watch -> iPhone -> Watch round trip on a timer:
/// each step sends a real CommandEnvelope over WatchConnectivity, the iPhone
/// mutates state and broadcasts context back, and the Watch UI updates.
/// Used to record the README demo GIF deterministically.
@MainActor
enum DemoDriver {
    static func runIfRequested(state: WatchAppState) {
        guard ProcessInfo.processInfo.environment["DEMO_AUTORUN"] == "1" else { return }

        Task {
            try? await Task.sleep(for: .seconds(4))
            send(.openGate(propertyID: state.propertyID, gateID: state.gateID))
            try? await Task.sleep(for: .seconds(4))
            send(.unlockDoor(propertyID: state.propertyID, doorID: state.doorID))
            try? await Task.sleep(for: .seconds(4))
            send(.closeGate(propertyID: state.propertyID, gateID: state.gateID))
            try? await Task.sleep(for: .seconds(4))
            send(.lockDoor(propertyID: state.propertyID, doorID: state.doorID))
        }
    }

    private static func send(_ command: WatchCommand) {
        try? WatchConnectivityClient.shared.send(CommandEnvelope(command: command))
    }
}
