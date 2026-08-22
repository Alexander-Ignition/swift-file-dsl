import Foundation
import Testing

extension TestTrait where Self == TemporaryDirectoryTrait {
    static var temporaryDirectory: TemporaryDirectoryTrait {
        TemporaryDirectoryTrait()
    }
}

struct TemporaryDirectoryTrait: TestScoping, TestTrait {
    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {

        let fileManager = FileManager.default

        let url = fileManager.temporaryDirectory.appendingPathComponent(
            "\(test.sourceLocation.fileName)-\(test.name)-\(test.sourceLocation.line)",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: false
        )
        defer {
            try! fileManager.removeItem(at: url)
        }
        try await TemporaryDirectory.$url.withValue(url, operation: function)
    }
}

struct TemporaryDirectory {
    @TaskLocal fileprivate static var url: URL?

    /// - Precondition: apply `@Test(.temporaryDirectory)` to the test
    static var current: TemporaryDirectory {
        TemporaryDirectory(url: url!)
    }

    let url: URL

    private init(url: URL) {
        self.url = url
    }

    func snapshot(
        sourceLocation: SourceLocation = #_sourceLocation,
        body: (inout DirectorySnapshot) throws -> Void
    ) throws {
        var dir = try DirectorySnapshot(url: url)
        try body(&dir)
        #expect(dir.unexpected == [], sourceLocation: sourceLocation)
    }
}

struct DirectorySnapshot: ~Copyable {
    let url: URL
    let contents: [String]

    private var expected: [String] = []
    fileprivate var unexpected: [String] {
        Set(contents).subtracting(expected).sorted()
    }

    init(url: URL) throws {
        self.url = url
        self.contents = try FileManager.default
            .contentsOfDirectory(atPath: url.path)
            .sorted()
        self.expected.reserveCapacity(self.contents.count)
    }

    mutating func file(
        _ name: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> String? {
        do {
            expected.append(name)
            let url = self.url.appending(component: name, directoryHint: .notDirectory)
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            Issue.record(error, sourceLocation: sourceLocation)
            return nil
        }
    }

    mutating func directory(
        _ name: String,
        sourceLocation: SourceLocation = #_sourceLocation,
        body: (inout DirectorySnapshot) throws -> Void
    ) throws {
        expected.append(name)
        let url = self.url.appending(component: name, directoryHint: .isDirectory)
        var dir = try DirectorySnapshot(url: url)
        try body(&dir)
        #expect(dir.unexpected == [], sourceLocation: sourceLocation)
    }
}
