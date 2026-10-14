// Original artwork for the Linebreak fork. No upstream icon assets are used.
import AppKit

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024,
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let body = NSBezierPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
NSGradient(starting: NSColor(srgbRed: 0.09, green: 0.25, blue: 0.30, alpha: 1),
           ending: NSColor(srgbRed: 0.26, green: 0.56, blue: 0.55, alpha: 1))!.draw(in: body, angle: 55)
let rope = NSBezierPath()
rope.move(to: CGPoint(x: 180, y: 745)); rope.line(to: CGPoint(x: 465, y: 525))
rope.move(to: CGPoint(x: 558, y: 525)); rope.line(to: CGPoint(x: 844, y: 745))
rope.lineWidth = 17; rope.lineCapStyle = .round
NSColor.white.withAlphaComponent(0.86).setStroke(); rope.stroke()
for (x, y, angle) in [(CGFloat(340), CGFloat(470), CGFloat(-14)), (CGFloat(680), CGFloat(360), CGFloat(18))] {
    NSGraphicsContext.saveGraphicsState()
    let t = NSAffineTransform(); t.translateX(by: x, yBy: y); t.rotate(byDegrees: angle); t.concat()
    NSColor.white.withAlphaComponent(0.96).setFill()
    NSBezierPath(roundedRect: CGRect(x: -103, y: -70, width: 206, height: 148), xRadius: 22, yRadius: 22).fill()
    NSColor(srgbRed: 0.53, green: 0.75, blue: 0.72, alpha: 1).setFill()
    NSBezierPath(roundedRect: CGRect(x: -85, y: -51, width: 170, height: 110), xRadius: 12, yRadius: 12).fill()
    NSGraphicsContext.restoreGraphicsState()
}
NSGraphicsContext.restoreGraphicsState()
let out = CommandLine.arguments.dropFirst().first ?? "linebreak-icon.png"
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
