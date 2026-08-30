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
                    WatchConnectivityClient.shared.whenActivated {
                        broadcastInitialState()
                    }
                }
        }
    }

    private func broadcastInitialState() {
        try? WatchConnectivityClient.shared.updateContext(viewModel.contextPayload)
    }
}
