import Quartz
import Commander

struct CLI {
    final class StandardErrorTextStream: TextOutputStream {
        func write(_ string: String) {
            FileHandle.standardError.write(string.data(using: .utf8)!)
        }
    }

    static let stdout = FileHandle.standardOutput
    static let stderr = FileHandle.standardError

    private static var _stderr = StandardErrorTextStream()
    static func printErr<T>(_ item: T) {
        Swift.print(item, to: &_stderr)
    }
}

extension NSBitmapImageRep {
    func png() -> Data? {
        return representation(using: .png, properties: [:])
    }
}

extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}

extension NSImage {
    func png() -> Data? {
        return tiffRepresentation?.bitmap?.png()
    }

    func resized(to size: Int) -> NSImage {
        let newSize = CGSize(width: size, height: size)

        let image = NSImage(size: newSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high

        draw(
            in: CGRect(origin: .zero, size: newSize),
            from: .zero,
            operation: .copy,
            fraction: 1
        )

        image.unlockFocus()
        return image
    }
}

func getIcon(pid: Int, size: Int) -> Data? {
    return NSRunningApplication(processIdentifier: pid_t(pid))?.icon?.resized(to: size).png()
}

func stringify(data: Data) -> String {
    return "data:image/png;base64,\(data.base64EncodedString())"
}

command(
    Argument<Int>("pid", description: "PID of the app"),
    Option("size", default: 32, description: "Size of the output icon"),
    Option("encoding", default: "base64", description: "Encoding of output icon")
) { pid, size, encoding in
    guard let icon = getIcon(pid: pid, size: size) else {
		CLI.printErr("Could not find app with PID \(pid)")
		exit(1)
    }

    if encoding == "buffer" {
        CLI.stdout.write(icon)
    } else {
        print(stringify(data: icon))
    }
}.run()
