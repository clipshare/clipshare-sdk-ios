// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ClipShare",
    platforms: [
         .iOS(.v13)
    ],
    products: [
        .library(
            name: "ClipShare",
            targets: ["ClipShareFramework"])
    ],
    targets: [
        .binaryTarget(
            name: "ClipShareFramework",
            path: "ClipShareFramework.xcframework"
        )
    ]
)