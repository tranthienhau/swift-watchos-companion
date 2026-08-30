# Screenshot / demo regeneration flow

How the committed `screenshots/` assets were captured.

## Prerequisites

- Xcode 15+ with iOS and watchOS simulator runtimes installed
  (`xcodebuild -downloadPlatform watchOS` if missing)
- `xcodegen` (`brew install xcodegen`)
- `ffmpeg` for GIF conversion

## Steps

1. Generate the project:

   ```bash
   xcodegen generate
   ```

2. Boot a paired iPhone + Watch simulator pair (create one if none exists):

   ```bash
   xcrun simctl list pairs
   # if empty:
   PHONE=$(xcrun simctl create "iPhone 17 Pro" "iPhone 17 Pro")
   WATCH=$(xcrun simctl create "Watch S10" "Apple Watch Series 10 (46mm)")
   xcrun simctl pair $WATCH $PHONE
   xcrun simctl boot $PHONE && xcrun simctl boot $WATCH
   ```

3. Build + install both targets:

   ```bash
   xcodebuild -project VivoControl.xcodeproj -scheme VivoControl \
     -destination "platform=iOS Simulator,id=$PHONE" build
   xcodebuild -project VivoControl.xcodeproj -scheme VivoControlWatch \
     -destination "platform=watchOS Simulator,id=$WATCH" build
   # install the built .app bundles from DerivedData with `xcrun simctl install`
   xcrun simctl launch $PHONE com.agileops.vivocontrol
   xcrun simctl launch $WATCH com.agileops.vivocontrol.watchkitapp
   ```

4. Run the scripted demo and record it. Launching the Watch app with
   `DEMO_AUTORUN=1` makes `DemoDriver` fire open-gate / unlock-door /
   close-gate / lock-door commands over WatchConnectivity every 4 seconds,
   so the round trip is exercised without synthetic UI taps:

   ```bash
   xcrun simctl terminate $WATCH com.agileops.vivocontrol.watchkitapp
   SIMCTL_CHILD_DEMO_AUTORUN=1 xcrun simctl launch $WATCH com.agileops.vivocontrol.watchkitapp
   xcrun simctl launch $PHONE com.agileops.vivocontrol
   xcrun simctl io $WATCH recordVideo --codec h264 -f /tmp/demo.mp4 &
   sleep 21 && kill -INT %1
   ```

   Capture stills at the right moments during the run (the launch order matters -
   start recording only after the Watch UI is on screen, otherwise the watch
   display may be asleep and the video records black frames):

   ```bash
   xcrun simctl io $WATCH screenshot screenshots/02-watch-home.png   # before demo starts
   xcrun simctl io $WATCH screenshot screenshots/03-watch-door.png   # mid-demo (gate open, door unlocked)
   xcrun simctl io $PHONE screenshot screenshots/01-ios-home.png     # after demo (full audit log)
   ```

5. Convert the recording to GIF (palette pass, 12 fps, 300 px wide):

   ```bash
   ffmpeg -i /tmp/demo.mp4 -vf "fps=12,scale=300:-1:flags=lanczos,palettegen" /tmp/pal.png
   ffmpeg -i /tmp/demo.mp4 -i /tmp/pal.png \
     -filter_complex "fps=12,scale=300:-1:flags=lanczos[x];[x][1:v]paletteuse" \
     screenshots/demo.gif
   ```

## How it works

The iPhone app seeds mock data in `VivoControlApp.init()` and broadcasts it via
`updateApplicationContext`. The Watch app applies that context to `WatchAppState`,
so the paired-simulator pair stays in sync with no backend. Watch button taps send
a `CommandEnvelope` back through `WatchConnectivityClient`; the iPhone mutates
state, records the audit entry, and re-broadcasts.
