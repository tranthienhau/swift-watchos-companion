import XCTest
@testable import Shared

final class CommandEnvelopeTests: XCTestCase {
    func testCommandEnvelopeRoundTripsThroughCodable() throws {
        let envelope = CommandEnvelope(
            command: .openGate(propertyID: UUID(), gateID: UUID())
        )

        let data = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(CommandEnvelope.self, from: data)

        XCTAssertEqual(envelope.id, decoded.id)
        XCTAssertEqual(envelope.command.auditLabel, decoded.command.auditLabel)
    }

    func testAuditLabelsAreStable() {
        XCTAssertEqual(WatchCommand.openGate(propertyID: UUID(), gateID: UUID()).auditLabel, "open_gate")
        XCTAssertEqual(WatchCommand.lockDoor(propertyID: UUID(), doorID: UUID()).auditLabel, "lock_door")
    }
}
