import Shared
import SwiftUI

@main
struct VivoControlWatchApp: App {
    @StateObject private var state = WatchAppState()

    var body: some Scene {
        WindowGroup {
            WatchHomeView(state: state)
                .onAppear {
                    WatchConnectivityClient.shared.onContextReceived = { context in
                        Task { @MainActor in
                            state.apply(context)
                        }
                    }
                    let pending = WatchConnectivityClient.shared.lastReceivedContext
                    if !pending.isEmpty {
                        state.apply(pending)
                    }
                    DemoDriver.runIfRequested(state: state)
                }
        }
    }
}

@MainActor
final class WatchAppState: ObservableObject {
    @Published var propertyName: String = "Loading..."
    @Published var gateState: GateState = .unknown
    @Published var doorLocked: Bool = true

    // Identifiers arrive from the iPhone via application context so commands
    // reference the same entities the iPhone seeded.
    var propertyID = UUID()
    var gateID = UUID()
    var doorID = UUID()

    func apply(_ context: [String: Any]) {
        if let name = context["property_name"] as? String { propertyName = name }
        if let raw = context["gate_state"] as? String, let state = GateState(rawValue: raw) {
            gateState = state
        }
        if let locked = context["door_locked"] as? Bool { doorLocked = locked }
        if let raw = context["property_id"] as? String, let id = UUID(uuidString: raw) { propertyID = id }
        if let raw = context["gate_id"] as? String, let id = UUID(uuidString: raw) { gateID = id }
        if let raw = context["door_id"] as? String, let id = UUID(uuidString: raw) { doorID = id }
    }
}
