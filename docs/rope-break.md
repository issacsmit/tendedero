# Pull-to-break implementation

`RopePull` owns a gesture from mouse-down through return/break completion. It snapshots all current item IDs at mouse-down. `RopeHostingView` routes rope hits to its native responder. The panel explicitly accepts mouse-moved events and sets its cursor after event dispatch; hover tracking uses `activeAlways` without `cursorUpdate`, because AppKit does not deliver cursor-update events in that scope. The polling fallback enables mouse input before setting the cursor. Leaving, hiding, or making the panel click-through restores the arrow without activating the app. `LinePanel` intercepts rope hits while preserving existing photo interactions and scrolling. The rope hit band is 18 points tall and excludes photo hit regions.

`RopeMotion` computes the stretched line, the actual grab point, two broken ends and accelerated slides followed by ballistic falls. Pull displacement has resistance and caps at 152 points; a 92-point effective displacement arms the gesture (about 104 points of pointer travel). Moving back below this threshold disarms it. Esc cancels. Release is the only commit point.

During the gesture, a transparent, click-through panel covers the display, allowing cards to fall past the original strip window. Drawing accounts for menu-bar and side-Dock offsets. A 60 Hz common-mode timer drives the release animation. Screen/Space changes interrupt visual work without committing an unfinished drag. Reduced Motion skips the release animation. There are no on-screen instructions; fraying and stretch provide feedback. Rope ends start fading 120 ms after the last card slides off, and disappear over 180 ms independently of the remaining fall.

A clear uses the same inbox-trash / external-file-detach policy as the existing corner action. It processes only the selected IDs, persists each successful removal, and leaves failures live. New screenshots are queued until the gesture completes. The overlay owns the fall, so the old single-card fall is suppressed. The existing menu clear action remains available.

## Native checks

- Hover a gap in the rope; verify hand cursor and click-through away from rope/photos.
- Pull briefly and release: all images return. Pull far, then back: no clear.
- Pull beyond threshold and press Esc: no clear.
- Pull beyond threshold and release: break at grabbed point, both sides slide in sequence, all entries clear.
- Repeat near either end and with more images than fit on screen.
- Capture another image during the drag/animation: it appears after completion.
- Move an inbox file to an unwritable location or inject a trash failure: unsuccessful items remain.
- Switch Space or change display arrangement mid-drag: no deletion.
- Check Reduce Motion, grab cursor, and the absence of text hints.
- Check with Dock at either side and a secondary monitor.

## Command Line Tools test workaround

Some Command Line Tools installations do not discover their Swift Testing macro library. On such hosts:

```sh
SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk \
swift test --disable-sandbox \
  -Xswiftc -load-plugin-library \
  -Xswiftc /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing/libTestingMacros.dylib
```

Use the SDK and toolchain paths installed on the host. Full Xcode installations normally need only `swift test`.

## Cursor regression (1.5.2)

The regression test sends native mouse-move events through a non-key panel with the real hosting view. It verifies native rope hit testing, open-hand / arrow transitions, click-through cleanup and unchanged app/key-window focus. This checks event routing and the application cursor; physical hover and the cursor displayed by WindowServer still require a user check. Apple documents the tracking-scope restriction under [activeAlways](https://developer.apple.com/documentation/appkit/nstrackingarea/options-swift.struct/activealways).
