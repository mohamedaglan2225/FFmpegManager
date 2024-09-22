// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FFmpegManager",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FFmpegManager",
            targets: ["FFmpegManager"]),
    ],
    targets: [
        .target(
            name: "FFmpegManager",
            dependencies: [
                "ffmpegkit",
                "libavformat",
                "libavcodec",
                "libavutil",
                "libavdevice",
                "libswresample",
                "libavfilter",
                "libswscale",
            ],
            path: "Sources",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "ffmpegkit",
            path: "Sources/Frameworks/ffmpegkit.xcframework"
        ),
        .binaryTarget(
            name: "libavformat",
            path: "Sources/Frameworks/libavformat.xcframework"
        ),
        .binaryTarget(
            name: "libavcodec",
            path: "Sources/Frameworks/libavcodec.xcframework"
        ),
        .binaryTarget(
            name: "libavutil",
            path: "Sources/Frameworks/libavutil.xcframework"
        ),
        .binaryTarget(
            name: "libavdevice",
            path: "Sources/Frameworks/libavdevice.xcframework"
        ),
        .binaryTarget(
            name: "libswresample",
            path: "Sources/Frameworks/libswresample.xcframework"
        ),
        .binaryTarget(
            name: "libavfilter",
            path: "Sources/Frameworks/libavfilter.xcframework"
        ),
        .binaryTarget(
            name: "libswscale",
            path: "Sources/Frameworks/libswscale.xcframework"
        )
    ]
)
