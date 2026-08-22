import Foundation
import Testing

extension SuiteTrait where Self == GitHubActionsTrait {
    static var gitHubActions: GitHubActionsTrait {
        GitHubActionsTrait()
    }
}

struct GitHubActionsTrait: SuiteTrait, TestScoping {

    var isRecursive: Bool {
        // Set to false to prevent duplicate execution in nested suites or tests,
        // avoiding multiple redundant triggers of `IssueHandlingTrait.compactMapIssues`.
        false
    }

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        guard GitHubActions.isEnabled else {
            return try await function()
        }
        return try await _gitHubIssueHandlingTrait.provideScope(
            for: test,
            testCase: testCase,
            performing: function
        )
    }
}

private let _gitHubIssueHandlingTrait = IssueHandlingTrait.compactMapIssues { (issue: Issue) in
    GitHubActions.log(
        issue.workflowCommand,
        file: issue.sourceLocation?.filePath,
        line: issue.sourceLocation?.line,
        message: "\(issue)"
    )
    return issue
}

private extension Issue {
    var workflowCommand: GitHubActions.WorkflowCommand {
        switch severity {
        case .warning:
            GitHubActions.WorkflowCommand.warning
        case .error:
            GitHubActions.WorkflowCommand.error
        @unknown default:
            GitHubActions.WorkflowCommand.error
        }
    }
}

/// [Workflow commands for GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands)
enum GitHubActions: Sendable {
    static let isEnabled: Bool = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"

    enum WorkflowCommand: String, Sendable {
        case warning
        case error
    }

    static func warning(file: String? = #filePath, line: Int? = #line, title: String? = nil, message: String) {
        log(.warning, file: file, line: line, message: message)
    }

    static func error(file: String? = #filePath, line: Int? = #line, title: String? = nil, message: String) {
        log(.error, file: file, line: line, message: message)
    }

    static func log(
        _ command: WorkflowCommand,
        file: String? = #filePath,
        line: Int? = #line,
        title: String? = nil,
        message: String,
    ) {
        func joinParameters() -> String {
            var parameters: [String] = []
            if let file {
                parameters.append("file=\(file)")
            }
            if let line {
                parameters.append("line=\(line)")
            }
            if let title {
                parameters.append("title=\(title)")
            }
            if parameters.isEmpty {
                return ""
            }
            return " " + parameters.joined(separator: ",")
        }
        print("::\(command)\(joinParameters())::\(message)")
    }
}
