// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ContentManager",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc).
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.6.1"),
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git", from: "0.1.0"),
        .package(url: "https://github.com/skelpo/SwiftyDates", from: "0.1.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "APIErrorMiddleware", "SwiftyDates", "JWTMiddleware", ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

