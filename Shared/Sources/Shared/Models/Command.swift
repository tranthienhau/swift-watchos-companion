import Foundation

/// Commands that the Watch can ask the iPhone to relay to the backend.
///
/// Encoded as a single Codable enum so the WatchConnectivity payload is one
/// JSON blob the receiving side can decode without sniffing keys.
public enum WatchCommand: Codable, Sendable {
    case openGate(propertyID: UUID, gateID: UUID)
    case closeGate(propertyID: UUID, gateID: UUID)
    case unlockDoor(propertyID: UUID, doorID: UUID)
    case lockDoor(propertyID: UUID, doorID: UUID)
    case requestSnapshot(propertyID: UUID, cameraID: UUID)

    public var auditLabel: String {
        switch self {
        case .openGate: return "open_gate"
        case .closeGate: return "close_gate"
        case .unlockDoor: return "unlock_door"
        case .lockDoor: return "lock_door"
        case .requestSnapshot: return "request_snapshot"
        }
    }
}

/// Wraps a command with an idempotency key so the iPhone can dedupe replays
/// when the Watch hands off a queued action.
public struct CommandEnvelope: Codable, Sendable {
    public let id: UUID
    public let issuedAt: Date
    public let command: WatchCommand

    public init(command: WatchCommand) {
        self.id = UUID()
        self.issuedAt = .now
        self.command = command
    }
}
