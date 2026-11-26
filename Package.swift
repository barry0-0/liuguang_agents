// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Liuguang",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Liuguang", targets: ["Liuguang"])],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle.git", exact: "2.10.0"),
        // SwiftTerm 1.20.0 plus `minimumContrastRatio`, cells sized by the character W, and Option-Left and Option-Right
        // kept as Esc b and Esc f; see docs/development/build-and-release.md#swiftterm-fork.
        .package(url: "https://github.com/yangzichao/SwiftTerm.git", exact: "1.20.0-justsessions.3"),
        .package(url: "https://github.com/cucumberswift/CucumberSwift.git", exact: "6.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "Liuguang",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "SwiftTerm", package: "SwiftTerm"),
            ],
            // `Resources/Guides` links to `docs/guides`. The native build system, which the release workflow's tests
            // use, would `.copy` the link itself, leading nowhere in the bundle; `.process` copies the guides, to the
            // bundle's top level, with either build system.
            resources: [
                .process("Assets.xcassets"), .copy("LiuGuangMark.png"), .process("Resources/Localization"), .copy("Resources/ReleaseNotes"), .copy("Resources/Fonts"), .process("Resources/Guides"),
            ],
            linkerSettings: [.linkedLibrary("sqlite3"), .linkedLibrary("z")]
        ),
        .testTarget(
            name: "LiuguangTests",
            dependencies: [
                "Liuguang",
                .product(name: "CucumberSwift", package: "CucumberSwift"),
            ],
            // CucumberSwift reads the Gherkin features from a resource folder that must be named Features.
            resources: [.copy("Gherkin/Features")]
        ),
    ]
)
