# Design - Google Stitch

Source-of-truth UI design for VivoControl, generated in Google Stitch
(project: [VivoControl - watchOS Companion](https://stitch.withgoogle.com/projects/4046634927342342220)).
The SwiftUI implementation follows these screens (layout, colors, typography, spacing).

| Screen | Preview | Code |
|---|---|---|
| iOS - Property Home (gates, doors, audit log) | `01-ios-home.png` | `01-ios-home.html` |
| Watch - Idle (gate closed, door locked) | `02-watch-idle.png` | `02-watch-idle.html` |
| Watch - Active (gate open, door unlocked) | `03-watch-active.png` | `03-watch-active.html` |

Design system highlights:

- Deep blue (`#0058bc`) for actionable security (door lock/unlock, primary CTAs)
- Vibrant green for open/active states, red (`#ba1a1a`) for close/stop actions
- Light system-gray canvas with white rounded cards (20px radius) on iOS
- Solid black, high-contrast pill buttons with oversized tap targets on watchOS
- Inter type scale (display 34/headline 22/body 17/label-caps 13)
