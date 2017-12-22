import Quartz
import Commander

extension NSBitmapImageRep {
    var png: Data? {
        return representation(using: .png, properties: [:])
    }
}

extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}

extension NSImage {
    var png: Data? {
        return tiffRepresentation?.bitmap?.png
    }
}

func getIcon(pid: Int) -> NSImage? {
    let runningApp = NSRunningApplication(processIdentifier: pid_t(pid))
    return runningApp?.icon
}

func resizeIcon(image: NSImage, w: Int, h: Int) -> NSImage {
    let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    let newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(
        in: NSMakeRect(0, 0, destSize.width, destSize.height),
        from: NSMakeRect(0, 0, image.size.width, image.size.height),
        operation: .sourceOver,
        fraction: CGFloat(1)
    )
    newImage.unlockFocus()
    newImage.size = destSize
    return NSImage(data: newImage.tiffRepresentation!)!
}

func stringifyImage(image: NSImage) -> String? {
    if let imgStr: String = image.png?.base64EncodedString() {
        return "data:image/png;base64,\(imgStr)"
    }
    return nil
}

command(
    Argument<Int>("pid", description: "pid of the Application"),
    Option("size", default: 32, description: "Size of out the output")
) { pid, size in
    if let icon = getIcon(pid: pid), let result = stringifyImage(image: resizeIcon(image: icon, w: size, h: size)) {
        print(result)
    }
}.run()
