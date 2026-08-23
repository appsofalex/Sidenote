import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("context")
}

ctx.setFillColor(CGColor(red: 0.945, green: 0.945, blue: 0.951, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

let ink = CGColor(red: 0.102, green: 0.102, blue: 0.106, alpha: 1)
ctx.setFillColor(ink)

let margin = CGRect(x: 286, y: 268, width: 36, height: 488)
let marginPath = CGPath(roundedRect: margin, cornerWidth: 18, cornerHeight: 18, transform: nil)
ctx.addPath(marginPath)
ctx.fillPath()

let line1 = CGRect(x: 360, y: 668, width: 292, height: 28)
ctx.addPath(CGPath(roundedRect: line1, cornerWidth: 14, cornerHeight: 14, transform: nil))
ctx.fillPath()

let line2 = CGRect(x: 360, y: 604, width: 196, height: 28)
ctx.addPath(CGPath(roundedRect: line2, cornerWidth: 14, cornerHeight: 14, transform: nil))
ctx.fillPath()

guard let image = ctx.makeImage() else { fatalError("image") }
let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("dest")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("write") }
