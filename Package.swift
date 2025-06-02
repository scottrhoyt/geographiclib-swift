// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeographicLib",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GeographicLib",
            targets: ["GeographicLib"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GeographicLib"),
        .target(
            name: "CGeographicLib",
            dependencies: [],
            exclude: [
                "./README.md",
                "./distrib-C",
                "./doc",
                "./proj-example",
                "./src/CMakeLists.txt",
                "./tests",
                "./tools",
                "./CMakeLists.txt",
                "./HOWTO-RELEASE.txt",
                "./LICENSE.txt",
            ],
            sources: ["./src"],
            publicHeadersPath: "./src",
            cSettings: [.headerSearchPath("./src")]
        ),
        .testTarget(
            name: "GeographicLibTests",
            dependencies: ["GeographicLib"]
        ),
    ]
)
