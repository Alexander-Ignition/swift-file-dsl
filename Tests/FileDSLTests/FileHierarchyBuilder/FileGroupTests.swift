import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct FileGroupTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {
        File("1.txt", string: "1")
        File("2.txt", string: "2")
        Directory("3") {
            File("4.txt", string: "4")
        }
    }

    @Test func build() {
        let tree = """
            .
            ├── 1.txt
            ├── 2.txt
            └── 3
                └── 4.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 3)

        #expect(type(of: fileHierarchy) == _FileGroup<File, File, Directory<File>>.self)


    }

    @Test func memoryLayout() {
        let fileSize = MemoryLayout<File>.size
        let dirSize = MemoryLayout<Directory<File>>.size
        #expect(MemoryLayout.size(ofValue: fileHierarchy) == 2 * fileSize + dirSize)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            #expect(dir.file("1.txt") == "1")
            #expect(dir.file("2.txt") == "2")

            try dir.directory("3") { dir in
                #expect(dir.file("4.txt") == "4")
            }
        }
    }
}
