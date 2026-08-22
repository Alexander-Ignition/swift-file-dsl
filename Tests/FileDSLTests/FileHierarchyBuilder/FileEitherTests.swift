import FileDSL
import Foundation
import Testing

@Suite(.gitHubActions)
struct FileEitherTests {

    // MARK: - if let

    @FileHierarchyBuilder
    private func file(name: String?) -> some FileHierarchy {
        if let name {
            File("\(name).txt", string: name)
        }
    }

    @Test func buildOptional() {
        let fileHierarchy = file(name: "A")
        let tree = """
            .
            └── A.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 1)
        #expect(type(of: fileHierarchy) == _FileEither<File, _EmptyFileHierarchy>.self)
    }

    @Test func buildOptionalNil() {
        let fileHierarchy = file(name: nil)
        #expect(fileHierarchy.treeDescription == ".")
        #expect(fileHierarchy.fileTreeCommands.count == 0)
        #expect(type(of: fileHierarchy) == _FileEither<File, _EmptyFileHierarchy>.self)
    }

    // MARK: - if else

    @FileHierarchyBuilder
    private func file(flag: Bool) -> some FileHierarchy {
        if flag {
            File("\(flag).txt", string: "\(flag)")
        } else {
            File("\(flag).txt", string: "\(flag)")
        }
    }

    @Test func buildEitherFirst() {
        let fileHierarchy = file(flag: true)
        let tree = """
            .
            └── true.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 1)
        #expect(type(of: fileHierarchy) == _FileEither<File, File>.self)
    }

    @Test func buildEitherSecond() {
        let fileHierarchy = file(flag: false)
        let tree = """
            .
            └── false.txt
            """
        #expect(fileHierarchy.treeDescription == tree)
        #expect(fileHierarchy.fileTreeCommands.count == 1)
        #expect(type(of: fileHierarchy) == _FileEither<File, File>.self)
    }
}
