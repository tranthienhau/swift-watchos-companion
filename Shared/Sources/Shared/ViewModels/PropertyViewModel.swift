import Foundation
import SwiftUI

/// Drives both the iOS and watchOS UIs from a single source of truth.
///
/// The iPhone owns the network calls; the Watch sends commands through
/// WatchConnectivity and renders the latest application context broadcast
/// from the iPhone.
@MainActor
public final class PropertyViewModel: ObservableObject {
    @Published public private(set) var property: Property
    @Published public private(set) var auditLog: [AuditEntry] = []

    public init(property: Property) {
        self.property = property
    }

    // MARK: - Local mutations (called after backend confirms)

    public func setGate(_ gateID: UUID, to state: GateState) {
        guard let index = property.gates.firstIndex(where: { $0.id == gateID }) else { return }
        property.gates[index].state = state
        property.gates[index].lastChangedAt = .now
        auditLog.append(.init(action: "gate_\(state.rawValue)", source: .iphone))
    }

    public func setDoor(_ doorID: UUID, locked: Bool) {
        guard let index = property.doors.firstIndex(where: { $0.id == doorID }) else { return }
        property.doors[index].locked = locked
        property.doors[index].lastChangedAt = .now
        auditLog.append(.init(action: locked ? "door_lock" : "door_unlock", source: .iphone))
    }

    public func record(_ envelope: CommandEnvelope) {
        auditLog.append(.init(action: envelope.command.auditLabel, source: .watch))
    }

    /// Snapshot broadcast to the Watch via updateApplicationContext. Carries
    /// entity IDs so Watch-issued commands reference the entities the iPhone
    /// actually owns.
    public var contextPayload: [String: Any] {
        [
            "property_name": property.name,
            "property_id": property.id.uuidString,
            "gate_state": property.gates.first?.state.rawValue ?? "unknown",
            "gate_id": property.gates.first?.id.uuidString ?? "",
            "door_locked": property.doors.first?.locked ?? true,
            "door_id": property.doors.first?.id.uuidString ?? "",
        ]
    }
}

public struct AuditEntry: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let timestamp = Date()
    public let action: String
    public let source: Source

    public enum Source: String, Sendable {
        case iphone
        case watch
    }
}
