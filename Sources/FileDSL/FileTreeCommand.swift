import Foundation

public struct FileTreeCommand: Sendable {
    /// Async file writer.
    public typealias Writer = @Sendable (_ fileURL: URL) async throws -> Void

    public enum Target: Sendable {
        case file(writer: Writer)
        case directory(commands: [FileTreeCommand])
    }

    public let name: String
    public let target: Target

    public init(name: String, target: Target) {
        self.name = name
        self.target = target
    }

    public init(name: String, commands: [FileTreeCommand]) {
        self.init(name: name, target: .directory(commands: commands))
    }

    public init(name: String, writer: @escaping Writer) {
        self.init(name: name, target: .file(writer: writer))
    }

    public init(name: String, string: String) {
        self.init(
            name: name,
            target: .file(writer: { fileURL in
                try string.write(to: fileURL, atomically: true, encoding: .utf8)
            }))
    }

    nonisolated(nonsending) func write(
        at baseURL: URL,
        fileManager: FileManager
    ) async throws {
        switch target {
        case .file(let writer):
            let url = baseURL.appending(component: name, directoryHint: .notDirectory)
            try await writer(url)

        case .directory(let items):
            let url = baseURL.appending(component: name, directoryHint: .isDirectory)
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            } catch let error as CocoaError where error.code == .fileWriteFileExists {
                // Ok, NSFileWriteFileExistsError
                // Could not perform an operation because the destination file already exists.
            }
            for item in items {
                try await item.write(at: url, fileManager: fileManager)
            }
        }
    }
}

// MARK: - Tree Description

extension FileTreeCommand {

    public var treeDescription: String {
        var lines = [name]
        appendChildrenLines(to: &lines, currentIndent: "")
        return lines.joined(separator: "\n")
    }

    private func appendChildrenLines(to lines: inout [String], currentIndent: String) {
        guard case .directory(let items) = target, !items.isEmpty else { return }

        for (index, item) in items.enumerated() {
            let isLast = index == items.count - 1

            let branch = isLast ? "└── " : "├── "
            lines.append(currentIndent + branch + item.name)

            let nextIndent = currentIndent + (isLast ? "    " : "│   ")
            item.appendChildrenLines(to: &lines, currentIndent: nextIndent)
        }
    }
}
