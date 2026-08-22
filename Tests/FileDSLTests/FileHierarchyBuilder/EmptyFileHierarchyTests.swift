import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct EmptyFileHierarchyTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {

    }

    @Test func build() {
        #expect(fileHierarchy.treeDescription == ".")
        #expect(fileHierarchy.fileTreeCommands.count == 0)
        #expect(type(of: fileHierarchy) == _EmptyFileHierarchy.self)
    }

    @Test func memoryLayout() {
        #expect(MemoryLayout.size(ofValue: fileHierarchy) == 0)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            #expect(dir.contents == [])
        }
    }
}
