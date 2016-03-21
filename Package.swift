import PackageDescription

let package = Package(
    name: "Data",
    dependencies: [
        .Package(url: "https://github.com/Zewo/System.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/swiftx/c7.git", majorVersion: 0, minor: 1)
    ]
)