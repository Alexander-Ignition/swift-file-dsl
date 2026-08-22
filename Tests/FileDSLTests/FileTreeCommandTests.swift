import Foundation
import Testing

@testable import FileDSL

@Suite(.gitHubActions)
struct FileTreeCommandTests {

    private var emptyFile: FileTreeCommand.Target {
        FileTreeCommand.Target.file(writer: {
            try Data().write(to: $0)
        })
    }

    @Test func treeDescription() {
        let packageFiles = FileTreeCommand(name: "PackageName", commands: [
            FileTreeCommand(name: "README.md", target: emptyFile),
            FileTreeCommand(name: "Sources", commands: [
                FileTreeCommand(name: "main.swift", target: emptyFile),
                FileTreeCommand(name: "Models", commands: [
                    FileTreeCommand(name: "User.swift", target: emptyFile),
                    FileTreeCommand(name: "FileItem.swift", target: emptyFile)
                ]),
                FileTreeCommand(name: "Utils.swift", target: emptyFile)
            ]),
            FileTreeCommand(name: "Tests", commands: [
                FileTreeCommand(name: "LinuxMain.swift", target: emptyFile)
            ]),
            FileTreeCommand(name: "Package.swift", target: emptyFile)
        ])

        let expected = """
            PackageName
            ├── README.md
            ├── Sources
            │   ├── main.swift
            │   ├── Models
            │   │   ├── User.swift
            │   │   └── FileItem.swift
            │   └── Utils.swift
            ├── Tests
            │   └── LinuxMain.swift
            └── Package.swift"
            """.dropLast()

        let actual = packageFiles.treeDescription
        #expect(actual.count == expected.count)
        #expect(actual == expected)
    }

    @Test(.temporaryDirectory)
    func `create file`() async throws {
        let tmp = TemporaryDirectory.current

        let command = FileTreeCommand(name: "1.json", string: #"{"id": 1}"#)
        try await command.write(at: tmp.url, fileManager: .default)

        try tmp.snapshot { dir in
            #expect(dir.file("1.json") == #"{"id": 1}"#)
        }
    }

    @Test(.temporaryDirectory)
    func `file exists`() async throws {
        let tmp = TemporaryDirectory.current

        let command1 = FileTreeCommand(name: "1.json", string: #"{"id": 1}"#)
        try await command1.write(at: tmp.url, fileManager: .default)

        let command2 = FileTreeCommand(name: "1.json", string: #"{"id": 2}"#)
        try await command2.write(at: tmp.url, fileManager: .default)

        try tmp.snapshot { dir in
            #expect(dir.file("1.json") == #"{"id": 2}"#)
        }
    }

    @Test(.temporaryDirectory)
    func `create directory`() async throws {
        let tmp = TemporaryDirectory.current

        let command = FileTreeCommand(name: "D", commands: [])
        try await command.write(at: tmp.url, fileManager: .default)

        try tmp.snapshot { dir in
            try dir.directory("D") { dir in
                #expect(dir.contents == [])
            }
        }
    }

    @Test(.temporaryDirectory)
    func `directory exists`() async throws {
        let tmp = TemporaryDirectory.current

        let command1 = FileTreeCommand(name: "N", commands: [
            FileTreeCommand(name: "1.json", string: #"{"id": 1}"#)
        ])
        try await command1.write(at: tmp.url, fileManager: .default)

        let command2 = FileTreeCommand(name: "N", commands: [
            FileTreeCommand(name: "2.json", string: #"{"id": 2}"#)
        ])
        try await command2.write(at: tmp.url, fileManager: .default)

        try tmp.snapshot { dir in
            try dir.directory("N") { dir in
                #expect(dir.file("1.json") == #"{"id": 1}"#)
                #expect(dir.file("2.json") == #"{"id": 2}"#)
            }
        }
    }
}
