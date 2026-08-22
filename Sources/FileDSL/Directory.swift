public struct Directory<Contents: FileHierarchy>: FileHierarchy {
    public let name: String
    public let contents: Contents

    public init(
        _ name: String,
        @FileHierarchyBuilder contents: () -> Contents
    ) {
        self.name = name
        self.contents = contents()
    }

    // MARK: - FileHierarchy

    public var files: Never { fatalError() }

    @inlinable
    public borrowing func _append(to commands: inout [FileTreeCommand]) {
        var children: [FileTreeCommand] = []
        contents._append(to: &children)
        commands.append(FileTreeCommand(name: name, commands: children))
    }
}
