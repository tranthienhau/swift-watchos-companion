import Shared
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PropertyViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Gates") {
                    ForEach(viewModel.property.gates) { gate in
                        HStack {
                            Text(gate.name)
                            Spacer()
                            Text(gate.state.rawValue.capitalized)
                                .foregroundStyle(gate.state == .open ? .green : .secondary)
                        }
                    }
                }

                Section("Doors") {
                    ForEach(viewModel.property.doors) { door in
                        HStack {
                            Text(door.name)
                            Spacer()
                            Image(systemName: door.locked ? "lock.fill" : "lock.open.fill")
                        }
                    }
                }

                Section("Audit log") {
                    ForEach(viewModel.auditLog.reversed()) { entry in
                        HStack {
                            Text(entry.action)
                            Spacer()
                            Text(entry.source.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.property.name)
        }
    }
}
