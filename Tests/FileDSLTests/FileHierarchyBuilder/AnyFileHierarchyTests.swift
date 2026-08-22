import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct AnyFileHierarchyTests {

    @FileHierarchyBuilder
    private var fileHierarchy: some FileHierarchy {
        if #available(macOS 15.0, iOS 18.0, *) {
            LimitedAvailabilityFile()
        } else {
            // Fallback on earlier versions
            File("Fallback.txt", string: "Fallback")
        }
    }

    @Test func buildLimitedAvailability() {
        let tree = """
            .
            └── LimitedAvailability.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 1)
        #expect(type(of: fileHierarchy) == _FileEither<AnyFileHierarchy, File>.self)
    }

    @Test(.temporaryDirectory)
    func write() async throws {
        let tmp = TemporaryDirectory.current

        try await fileHierarchy.write(at: tmp.url)

        try tmp.snapshot { dir in
            #expect(dir.file("LimitedAvailability.txt") == "macOS 15.0, iOS 18.0")
        }
    }
}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
struct LimitedAvailabilityFile: FileHierarchy {
    var files: some FileHierarchy {
        File("LimitedAvailability.txt", string: "macOS 15.0, iOS 18.0")
    }
}
