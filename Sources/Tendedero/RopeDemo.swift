#if DEBUG
import AppKit

/// An isolated, opt-in fixture for testing the native gesture. It never
/// starts screenshot/clipboard watchers or changes screenshot preferences.
@MainActor
enum RopeDemo {
    static func populate(_ line: Line) {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("Linebreak-demo-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let colors: [NSColor] = [.systemTeal, .systemBlue, .systemIndigo, .systemOrange, .systemGreen]
        for i in 0..<5 {
            let image = NSImage(size: NSSize(width: 320, height: 210))
            image.lockFocus()
            colors[i].withAlphaComponent(0.8).setFill()
            NSBezierPath(rect: CGRect(x: 0, y: 0, width: 320, height: 210)).fill()
            NSColor.white.withAlphaComponent(0.8).setFill()
            for row in 0..<4 {
                NSBezierPath(roundedRect: CGRect(x: 32, y: 40 + row * 32, width: row == 3 ? 140 : 245, height: 9), xRadius: 4, yRadius: 4).fill()
            }
            image.unlockFocus()
            guard let tiff = image.tiffRepresentation,
                  let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) else { continue }
            let url = folder.appendingPathComponent("Sample-\(i + 1).png")
            try? png.write(to: url)
            line.hang(url, quietly: true)
        }
    }
}
#endif
