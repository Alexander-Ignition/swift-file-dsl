import Foundation
import FileDSL
import Testing

@Suite(.gitHubActions)
struct DirectoryTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {
        Directory("swift-package") {
            File("README.md", string: "# swift-package-name")
            Directory("Sources") {
                File("main.swift", string: "func main() {}")
            }
        }
    }

    @Test func build() {
        let tree = """
            .
            └── swift-package
                ├── README.md
                └── Sources
                    └── main.swift
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 1)
        #expect(type(of: fileHierarchy) == Directory<_FileGroup<File, Directory<File>>>.self)
    }

    @Test func memoryLayout() {
        let fileSize = MemoryLayout<File>.size
        #expect(MemoryLayout<Directory<File>>.size == MemoryLayout<String>.size + fileSize)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            try dir.directory("swift-package") { dir in
                #expect(dir.file("README.md") == "# swift-package-name")
                try dir.directory("Sources") { dir in
                    #expect(dir.file("main.swift") == "func main() {}")
                }
            }
        }
    }
}
