import AppKit
import SwiftUI

/// SwiftUI can reset the cursor during mouse movement. Own the rope's cursor
/// region at the AppKit level so the affordance stays visible while hovering.
final class RopeHostingView: NSHostingView<LineView> {
    weak var ropePull: RopePull?
    private var ropeTracking: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let ropeTracking { removeTrackingArea(ropeTracking) }
        let tracking = NSTrackingArea(rect: .zero,
            options: [.inVisibleRect, .activeAlways, .cursorUpdate, .mouseMoved, .mouseEnteredAndExited],
            owner: self)
        addTrackingArea(tracking)
        ropeTracking = tracking
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        guard let window, let ropePull, !ropePull.isActive else { return }
        for x in stride(from: CGFloat(12), to: bounds.width - 12, by: 6) {
            let y = Layout.ropeY(x: x, width: bounds.width)
            let screen = window.convertPoint(toScreen: CGPoint(x: x, y: bounds.height - y))
            guard ropePull.canGrab(at: screen) else { continue }
            addCursorRect(CGRect(x: x - 3, y: isFlipped ? y - 9 : bounds.height - y - 9,
                                 width: 6, height: 18), cursor: .openHand)
        }
    }

    override func cursorUpdate(with event: NSEvent) {
        super.cursorUpdate(with: event)
        updateRopeCursor()
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        updateRopeCursor()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        updateRopeCursor()
    }

    private func updateRopeCursor() {
        if ropePull?.isDragging == true { NSCursor.closedHand.set() }
        else if ropePull?.canGrab(at: NSEvent.mouseLocation) == true { NSCursor.openHand.set() }
    }
}

/// A transparent strip along the top of the screen that floats over every
/// app and every Space except full screen ones. It leaves the front app active
/// and lets clicks pass through everywhere except photos and the grabbable rope.
final class LinePanel: NSPanel {
    weak var ropePull: RopePull?
    init(content: NSView) {
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .floating
        // Every Space, full screen ones included. Whether the line comes down
        // over a full screen app is up to the user, see FullScreen.showLineOver.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        isMovable = false
        becomesKeyOnlyIfNeeded = true
        ignoresMouseEvents = true
        contentView = content
    }

    /// Two-finger swipes and the scroll wheel, for moving along a long line.
    var onScroll: ((NSEvent) -> Void)?

    override func sendEvent(_ event: NSEvent) {
        let screenPoint = convertPoint(toScreen: event.locationInWindow)
        if let ropePull {
            if event.type == .leftMouseDown, ropePull.begin(at: screenPoint) { return }
            if ropePull.isDragging {
                switch event.type {
                case .leftMouseDragged: ropePull.drag(to: screenPoint); return
                case .leftMouseUp:
                    ropePull.drag(to: screenPoint)
                    ropePull.release()
                    return
                case .keyDown where event.keyCode == 53: ropePull.release(cancelled: true); return
                default: break
                }
            }
            if ropePull.isActive, [.scrollWheel, .leftMouseDown, .rightMouseDown].contains(event.type) { return }
        }
        if event.type == .scrollWheel, let onScroll {
            onScroll(event)
        } else {
            super.sendEvent(event)
        }
    }

    override var canBecomeKey: Bool { ropePull?.isDragging == true }
    override var canBecomeMain: Bool { false }

    /// The line hangs on the screen you are using, which is the one with the
    /// pointer: that is where you just took the screenshot.
    static func screenUnderPointer() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
            ?? NSScreen.main ?? NSScreen.screens.first
    }

    func placeOnScreen(_ screen: NSScreen? = nil) {
        guard let visible = (screen ?? LinePanel.screenUnderPointer())?.visibleFrame else { return }
        let target = NSRect(x: visible.minX, y: visible.maxY - Layout.panelHeight,
                            width: visible.width, height: Layout.panelHeight)
        if frame != target { setFrame(target, display: true) }
    }
}
