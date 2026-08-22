public import Foundation

public struct File: FileHierarchy {
    public let name: String
    public let writer: FileTreeCommand.Writer

    public init(_ name: String, writer: @escaping FileTreeCommand.Writer) {
        self.name = name
        self.writer = writer
    }

    public init(_ name: String, string: String) {
        self.name = name
        self.writer = { url in
            try string.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    public init(_ name: String, data: Data) {
        self.name = name
        self.writer = { url in
            try data.write(to: url, options: .atomic)
        }
    }

    // MARK: - FileHierarchy

    public var files: some FileHierarchy { fatalError() }

    @inlinable
    public borrowing func _append(to nodes: inout [FileTreeCommand]) {
        nodes.append(FileTreeCommand(name: name, writer: writer))
    }
}
