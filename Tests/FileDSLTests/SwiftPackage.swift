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
