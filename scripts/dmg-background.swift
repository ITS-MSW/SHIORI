import AppKit

// Match the existing landing-page palette and three-bar brand mark.
let width = 660, height = 440
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor(srgbRed: 0.94, green: 0.92, blue: 0.97, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
NSColor(srgbRed: 0.13, green: 0.10, blue: 0.21, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 290, width: width, height: 150)).fill()
for (index, color) in [NSColor(srgbRed: 0.996, green: 0.616, blue: 0.486, alpha: 1),
    NSColor(srgbRed: 0.659, green: 0.898, blue: 0.812, alpha: 1),
    NSColor(srgbRed: 0.722, green: 0.545, blue: 0.851, alpha: 1)].enumerated() {
    color.setFill()
    NSBezierPath(roundedRect: NSRect(x: 261 + index * 10, y: 355, width: 7, height: 28),
        xRadius: 3.5, yRadius: 3.5).fill()
}
func text(_ value: String, y: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight) {
    let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color]
    let string = value as NSString
    let textWidth = string.size(withAttributes: attributes).width
    string.draw(at: NSPoint(x: (CGFloat(width) - textWidth) / 2, y: y), withAttributes: attributes)
}
("SHIORI" as NSString).draw(at: NSPoint(x: 301, y: 355), withAttributes: [
    .font: NSFont.systemFont(ofSize: 23, weight: .semibold), .foregroundColor: NSColor.white])
text("Drag SHIORI to Applications", y: 308, size: 20, color: .white, weight: .medium)
text("→", y: 190, size: 48, color: NSColor(white: 0.3, alpha: 1), weight: .regular)
text("Your thoughts, within reach.", y: 56, size: 15, color: NSColor(white: 0.35, alpha: 1), weight: .regular)
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
