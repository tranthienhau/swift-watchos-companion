# Swift watchOS Companion POC

A SwiftUI iOS + watchOS companion app proof-of-concept that mirrors the architecture used by residential community control systems (think Vivo Control style: gates, doors, cameras, residents). The repo demonstrates the full set of patterns you need to ship a watchOS companion to the App Store: paired-device sync via WatchConnectivity, complications, background updates, and a clean shared model layer that lives in a Swift package consumed by both targets.

## What this POC demonstrates

- Two app targets: iOS host (`VivoControl`) and watchOS companion (`VivoControlWatch`)
- Shared Swift package (`Shared`) consumed by both targets so models, transport, and view models are written once
- WatchConnectivity session manager that supports `sendMessage`, `transferUserInfo`, and `updateApplicationContext`
- Live state sync from iOS to Watch (gate state, door state, last camera snapshot)
- Watch-initiated commands (Open Gate, Unlock Door) routed through the iOS app to the backend
- ComplicationController with multiple complication families (modular, circular, corner)
- Background refresh with `WKApplicationRefreshBackgroundTask` for periodic state updates
- Authentication and command audit log so every Watch action is traceable
- SwiftUI for both targets, no UIKit shims, strict concurrency

## Why this matters for the Vivo Control job

The job needs:
- 5+ years of professional mobile development - shown by the breadth of patterns here
- Proven watchOS experience with concept-to-App-Store delivery
- Track record of shipping on App Store and Google Play
- Hardware integration patterns (Axis cameras, Twilio, Particle relay cards) - the gate/door command flow in this POC is the same shape

This POC is not a toy: it implements the exact patterns you need to ship a watchOS companion that controls real hardware via a backend.

## Architecture

```
.
├── iOS/VivoControl/                  # iPhone app target
│   ├── VivoControlApp.swift          # @main entry, sets up WC session
│   ├── HomeView.swift                # Properties + quick actions
│   └── PhoneSessionDelegate.swift    # Receives Watch commands, hits backend
├── Watch/VivoControlWatch/           # Apple Watch target
│   ├── VivoControlWatchApp.swift     # @main entry, sets up WC session
│   ├── WatchHomeView.swift           # Compact gate/door controls
│   ├── ComplicationController.swift  # Complications for watch face
│   └── WatchSessionDelegate.swift    # Sends commands, receives state
└── Shared/                           # Swift package consumed by both targets
    ├── Sources/Shared/
    │   ├── Models/                   # Property, Gate, Door, Camera
    │   ├── Transport/                # WatchConnectivityClient
    │   └── ViewModels/               # PropertyViewModel
    └── Package.swift
```

## How the watch-to-iPhone-to-backend flow works

1. User taps "Open Gate" on the Watch
2. `WatchSessionDelegate` calls `session.sendMessage` with a `GateCommand` payload
3. `PhoneSessionDelegate` on the iPhone receives the message and calls the Vivo Control backend
4. The backend confirms and the iPhone broadcasts the new gate state via `updateApplicationContext`
5. The Watch UI updates and the complication is reloaded

If the Watch is out of range, `transferUserInfo` queues the command for delivery when the iPhone reconnects, so a user pressing "Open Gate" while leaving the house never loses the action.

## Run

Open `swift-watchos-companion.xcworkspace` (or generate with `xcodegen` from the included `project.yml`) in Xcode 15+, select the iOS scheme, and run on a paired iPhone + Apple Watch simulator pair.
