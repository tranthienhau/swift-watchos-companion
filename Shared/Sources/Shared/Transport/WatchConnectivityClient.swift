import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Cross-platform WatchConnectivity client used by both the iOS host and the
/// watchOS companion. The same class is built into both targets via the
/// Shared Swift package, so there is exactly one place to maintain the wire
/// format.
///
/// Three transport methods are exposed:
///   - sendMessage:   live, requires the counterpart app to be reachable
///   - transferUserInfo: queued, delivered when the counterpart wakes up
///   - updateApplicationContext: latest-state-only broadcast (e.g. gate state)
@MainActor
public final class WatchConnectivityClient: NSObject, ObservableObject {
    public static let shared = WatchConnectivityClient()

    @Published public private(set) var lastReceivedContext: [String: Any] = [:]
    @Published public private(set) var lastReceivedCommand: CommandEnvelope?

    public var onCommandReceived: ((CommandEnvelope) -> Void)?
    public var onContextReceived: (([String: Any]) -> Void)?
    /// Fired once WCSession activation completes. Sending before activation
    /// throws, so state broadcasts must wait for this instead of onAppear.
    public var onActivated: (() -> Void)?
    private var activated = false

    /// Runs the block after WCSession activation - immediately if the session
    /// is already active, otherwise once activationDidCompleteWith fires.
    public func whenActivated(_ block: @escaping () -> Void) {
        if activated { block() } else { onActivated = block }
    }

    private override init() {
        super.init()
        activate()
    }

    public func activate() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        #endif
    }

    // MARK: - Sending

    /// Best-effort live message. Falls back to transferUserInfo if the
    /// counterpart is unreachable, so the user never loses a command.
    public func send(_ envelope: CommandEnvelope) throws {
        #if canImport(WatchConnectivity)
        let data = try JSONEncoder().encode(envelope)
        let payload: [String: Any] = ["envelope": data]

        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { _ in
                session.transferUserInfo(payload)
            }
        } else {
            session.transferUserInfo(payload)
        }
        #endif
    }

    /// Broadcast latest application state (gate/door snapshot). Only the most
    /// recent context is retained by the system, so this is cheap to call on
    /// every state change.
    public func updateContext(_ context: [String: Any]) throws {
        #if canImport(WatchConnectivity)
        try WCSession.default.updateApplicationContext(context)
        #endif
    }
}

#if canImport(WatchConnectivity)
extension WatchConnectivityClient: WCSessionDelegate {
    public nonisolated func session(_ session: WCSession,
                        activationDidCompleteWith state: WCSessionActivationState,
                        error: Error?) {
        guard state == .activated else { return }
        // Deliver any context that arrived while this app was not running,
        // then let the app push its own initial state.
        let pending = session.receivedApplicationContext
        Task { @MainActor in
            if !pending.isEmpty {
                self.lastReceivedContext = pending
                self.onContextReceived?(pending)
            }
            self.activated = true
            self.onActivated?()
        }
    }

    #if os(iOS)
    public nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    public nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    public nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.handleIncoming(message)
        }
    }

    public nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            self.handleIncoming(userInfo)
        }
    }

    public nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.lastReceivedContext = applicationContext
            self.onContextReceived?(applicationContext)
        }
    }

    @MainActor
    private func handleIncoming(_ payload: [String: Any]) {
        if let data = payload["envelope"] as? Data,
           let envelope = try? JSONDecoder().decode(CommandEnvelope.self, from: data) {
            lastReceivedCommand = envelope
            onCommandReceived?(envelope)
        }
    }
}
#endif
