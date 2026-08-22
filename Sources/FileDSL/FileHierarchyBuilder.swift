@resultBuilder
public enum FileHierarchyBuilder {

    @inlinable
    public static func buildBlock() -> _EmptyFileHierarchy {
        _EmptyFileHierarchy()
    }

    @inlinable
    public static func buildBlock<T: FileHierarchy>(_ component: T) -> T {
        component
    }

    @inlinable
    public static func buildBlock<each T: FileHierarchy>(
        _ component: repeat each T
    ) -> some FileHierarchy {
        _FileGroup(contents: (repeat each component))
    }

    // MARK: - if let

    @inlinable
    public static func buildOptional<T: FileHierarchy>(
        _ component: T?
    ) -> _FileEither<T, _EmptyFileHierarchy> {
        if let component {
            return _FileEither<T, _EmptyFileHierarchy>.first(component)
        }
        return _FileEither<T, _EmptyFileHierarchy>.second(_EmptyFileHierarchy())
    }

    // MARK: - if else

    @inlinable
    public static func buildEither<True: FileHierarchy, False: FileHierarchy>(
        first component: True
    ) -> _FileEither<True, False> {
        _FileEither<True, False>.first(component)
    }

    @inlinable
    public static func buildEither<True: FileHierarchy, False: FileHierarchy>(
        second component: False
    ) -> _FileEither<True, False> {
        _FileEither<True, False>.second(component)
    }

    // MARK: - if #available

    @inlinable
    public static func buildLimitedAvailability<T: FileHierarchy>(_ component: T) -> AnyFileHierarchy {
        AnyFileHierarchy(component)
    }

    // MARK: - for in

    @inlinable
    public static func buildArray<T: FileHierarchy>(_ components: [T]) -> _FileArray<T> {
        _FileArray(array: components)
    }
}

extension Never: FileHierarchy {
    public var files: Never { fatalError() }
}

public struct AnyFileHierarchy: FileHierarchy {
    public var files: Never { fatalError() }

    @usableFromInline
    let _appendHandler: @Sendable (inout [FileTreeCommand]) -> Void

    @inlinable
    public init<T: FileHierarchy>(_ base: T) {
        _appendHandler = base._append(to:)
    }

    @inlinable
    public borrowing func _append(to commands: inout [FileTreeCommand]) {
        _appendHandler(&commands)
    }
}

public struct _EmptyFileHierarchy: FileHierarchy {
    public var files: Never { fatalError() }

    @usableFromInline
    init() {}

    @inlinable
    public func _append(to commands: inout [FileTreeCommand]) {}
}

public struct _FileGroup<each Element: FileHierarchy>: FileHierarchy {
    public let contents: (repeat each Element)

    @usableFromInline
    init(contents: (repeat each Element)) {
        self.contents = contents
    }

    public var files: Never { fatalError() }

    @inlinable
    public borrowing func _append(to commands: inout [FileTreeCommand]) {
        for content in repeat each contents {
            content._append(to: &commands)
        }
    }
}

public enum _FileEither<First: FileHierarchy, Second: FileHierarchy>: FileHierarchy {
    case first(First)
    case second(Second)

    public var files: Never { fatalError() }

    @inlinable
    public func _append(to commands: inout [FileTreeCommand]) {
        switch self {
        case .first(let content):
            content._append(to: &commands)
        case .second(let content):
            content._append(to: &commands)
        }
    }
}

public struct _FileArray<Element: FileHierarchy>: FileHierarchy {
    @usableFromInline
    let array: [Element]

    @usableFromInline
    init(array: [Element]) {
        self.array = array
    }

    public var files: Never { fatalError() }

    @inlinable
    public borrowing func _append(to commands: inout [FileTreeCommand]) {
        for element in array {
            element._append(to: &commands)
        }
    }
}
