# swift-file-dsl

[![Test](https://github.com/Alexander-Ignition/swift-file-dsl/actions/workflows/test.yml/badge.svg)](https://github.com/Alexander-Ignition/swift-file-dsl/actions/workflows/test.yml)
[![Swift 6.2](https://img.shields.io/badge/swift-6.3-brightgreen.svg?style=flat)](https://www.swift.org)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Alexander-Ignition/swift-file-dsl/blob/main/LICENSE)

```swift
import FileDSL
import Foundation

struct SwiftPackage: FileHierarchy {
    let name: String

    var files: some FileHierarchy {
        Directory(name) {
            File("README.md", string: "# \(name)")
            File("Package.swift", string: "TODO: \(name)")
            Directory("Sources") {
                Directory(name) {
                    File("\(name).swift", string: "// TODO: \(name)")
                }
            }
            Directory("Tests") {
                Directory("\(name)Tests") {
                    File("\(name)Tests.swift", string: "// TODO: tests")
                }
            }
        }
    }
}

let files = SwiftPackage(name: "MyKit")
let url: URL = // ...
try await files.write(at: url)

print(files.treeDescription)
```
