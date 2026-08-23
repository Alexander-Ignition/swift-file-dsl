import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct FileTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {
        File("README.md", string: "# Title")
        File("1.txt", data: Data("A".utf8))
        File("2.txt") { fileURL in
            try Data("B".utf8).write(to: fileURL, options: .atomic)
        }
    }

    @Test func build() {
        let tree = """
            .
            ├── README.md
            ├── 1.txt
            └── 2.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 2)
        #expect(type(of: fileHierarchy) == _FileGroup<File, File, File>.self)
    }

    @Test func memoryLayout() {
        let fileSize = MemoryLayout<File>.size
        #expect(fileSize == MemoryLayout<String>.size + MemoryLayout<FileTreeCommand.Writer>.size)
        #expect(MemoryLayout.size(ofValue: fileHierarchy) == 3 * fileSize)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            #expect(dir.file("1.txt") == "A")
            #expect(dir.file("2.txt") == "B")
            #expect(dir.file("README.md") == "# Title")
        }
    }
}
