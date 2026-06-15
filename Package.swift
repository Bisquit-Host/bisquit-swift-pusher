// swift-tools-version:6.3.2

import PackageDescription

let package = Package(
    name: "bisquit-swift-pusher",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // HTTP framework
        // https://github.com/vapor/vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
        
        // Networking
        // https://github.com/apple/swift-nio
            .package(url: "https://github.com/apple/swift-nio.git", from: "2.99.0"),
        
        // APNS
        // https://github.com/vapor/apns
            .package(url: "https://github.com/vapor/apns.git", from: "5.0.0"),
        
        // TOTP
        // https://github.com/lachlanbell/SwiftOTP
            .package(url: "https://github.com/lachlanbell/SwiftOTP.git", from: "3.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "bisquit-swift-pusher",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "VaporAPNS", package: "apns"),
                .product(name: "SwiftOTP", package: "swiftotp")
            ],
            swiftSettings: swiftSettings
        ),
        //        .testTarget(
        //            name: "PyzhCloudTests",
        //            dependencies: [
        //                .target(name: "PyzhCloud"),
        //                .product(name: "VaporTesting", package: "vapor")
        //            ],
        //            swiftSettings: swiftSettings
        //        )
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] {[
    .enableUpcomingFeature("ExistentialAny")
]}
