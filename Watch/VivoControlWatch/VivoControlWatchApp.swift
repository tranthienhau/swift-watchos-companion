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
                }
        }
    }
}

@MainActor
final class WatchAppState: ObservableObject {
    @Published var propertyName: String = "Loading..."
    @Published var gateState: GateState = .unknown
    @Published var doorLocked: Bool = true

    // Identifiers come from the iPhone via context in production. Hard-coded
    // here so the POC builds without an extra round-trip.
    let propertyID = UUID()
    let gateID = UUID()
    let doorID = UUID()

    func apply(_ context: [String: Any]) {
        if let name = context["property_name"] as? String { propertyName = name }
        if let raw = context["gate_state"] as? String, let state = GateState(rawValue: raw) {
            gateState = state
        }
        if let locked = context["door_locked"] as? Bool { doorLocked = locked }
    }
}
