import Shared
import SwiftUI

@main
struct VivoControlApp: App {
    @StateObject private var viewModel: PropertyViewModel
    @StateObject private var session = WatchConnectivityClient.shared

    init() {
        let property = Property(
            name: "Calle del Mar 12",
            address: "San Juan, PR",
            gates: [Gate(name: "Main Gate", state: .closed)],
            doors: [Door(name: "Front Door", locked: true)],
            cameras: [Camera(name: "Driveway", snapshotURL: nil)]
        )
        _viewModel = StateObject(wrappedValue: PropertyViewModel(property: property))
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel)
                .onAppear {
                    WatchConnectivityClient.shared.onCommandReceived = { envelope in
                        Task { @MainActor in
                            PhoneCommandHandler(viewModel: viewModel).handle(envelope)
                        }
                    }
                    broadcastInitialState()
                }
        }
    }

    private func broadcastInitialState() {
        let context: [String: Any] = [
            "property_name": viewModel.property.name,
            "gate_state": viewModel.property.gates.first?.state.rawValue ?? "unknown",
            "door_locked": viewModel.property.doors.first?.locked ?? true,
        ]
        try? WatchConnectivityClient.shared.updateContext(context)
    }
}
