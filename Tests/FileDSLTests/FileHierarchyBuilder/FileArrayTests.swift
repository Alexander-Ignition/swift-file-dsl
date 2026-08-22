import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct FileArrayTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {
        for i in 0..<3 {
            File("\(i).txt", string: "\(i)")
        }
    }

    @Test func build() {
        let tree = """
            .
            ├── 0.txt
            ├── 1.txt
            └── 2.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 3)

        #expect(type(of: fileHierarchy) == _FileArray<File>.self)
        #expect(MemoryLayout.size(ofValue: fileHierarchy) == MemoryLayout<[File]>.size)
    }

    @Test func memoryLayout() {
        #expect(MemoryLayout.size(ofValue: fileHierarchy) == MemoryLayout<[File]>.size)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            #expect(dir.file("0.txt") == "0")
            #expect(dir.file("1.txt") == "1")
            #expect(dir.file("2.txt") == "2")
        }
    }
}
