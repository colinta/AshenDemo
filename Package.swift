// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "AshenDemo",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "AshenDemo", targets: ["AshenDemo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/colinta/Ashen.git", .revision("efd81c6")),
        // .package(path: "../Ashen"),
    ],
    targets: [
        .target(name: "AshenDemo", dependencies: ["Ashen"]),
    ]
)
