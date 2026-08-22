public import Foundation

public protocol FileHierarchy: Sendable {
    associatedtype Files: FileHierarchy

    @FileHierarchyBuilder
    var files: Files { get }

    borrowing func _append(to commands: inout [FileTreeCommand])
}

extension FileHierarchy {
    @inlinable
    public borrowing func _append(to commands: inout [FileTreeCommand]) {
        files._append(to: &commands)
    }

    public var fileTreeCommands: [FileTreeCommand] {
        var commands: [FileTreeCommand] = []
        _append(to: &commands)
        return commands
    }

    public var treeDescription: String {
        let current = FileTreeCommand(name: ".", commands: fileTreeCommands)
        return current.treeDescription
    }

    nonisolated(nonsending) public func write(
        at baseURL: URL,
        fileManager: FileManager = .default
    ) async throws {
        for command in fileTreeCommands {
            try await command.write(at: baseURL, fileManager: fileManager)
        }
    }
}
