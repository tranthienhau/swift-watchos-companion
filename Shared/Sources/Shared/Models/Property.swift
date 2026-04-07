import Foundation

/// A residential property managed by the dealer. The Watch and iPhone both
/// render this same model so the data shape stays in lockstep.
public struct Property: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let address: String
    public var gates: [Gate]
    public var doors: [Door]
    public var cameras: [Camera]

    public init(
        id: UUID = UUID(),
        name: String,
        address: String,
        gates: [Gate],
        doors: [Door],
        cameras: [Camera]
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.gates = gates
        self.doors = doors
        self.cameras = cameras
    }
}

public struct Gate: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public var state: GateState
    public var lastChangedAt: Date

    public init(id: UUID = UUID(), name: String, state: GateState, lastChangedAt: Date = .now) {
        self.id = id
        self.name = name
        self.state = state
        self.lastChangedAt = lastChangedAt
    }
}

public enum GateState: String, Codable, Sendable {
    case open
    case closed
    case opening
    case closing
    case unknown
}

public struct Door: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public var locked: Bool
    public var lastChangedAt: Date

    public init(id: UUID = UUID(), name: String, locked: Bool, lastChangedAt: Date = .now) {
        self.id = id
        self.name = name
        self.locked = locked
        self.lastChangedAt = lastChangedAt
    }
}

public struct Camera: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let snapshotURL: URL?

    public init(id: UUID = UUID(), name: String, snapshotURL: URL?) {
        self.id = id
        self.name = name
        self.snapshotURL = snapshotURL
    }
}
