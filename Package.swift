// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "NotationModel",
    products: [
        .library(name: "PlotModel", targets: ["PlotModel"]),
        .library(name: "SpelledPitch", targets: ["SpelledPitch"]),
        .library(name: "SpelledRhythm", targets: ["SpelledRhythm"]),
        .library(name: "StaffModel", targets: ["StaffModel"])
    ],
    dependencies: [
        .package(url: "https://github.com/dn-m/Structure", from: "0.23.0"),
        .package(url: "https://github.com/dn-m/Math", from: "0.7.1"),
        .package(url: "https://github.com/dn-m/Music", from: "0.15.0")
    ],
    targets: [
        // Sources
        .target(name: "PlotModel", dependencies: ["DataStructures"]),
        .target(name: "SpelledPitch", dependencies: ["Pitch", "DataStructures"]),
        .target(name: "SpelledRhythm", dependencies: ["Duration"]),
        .target(name: "StaffModel", dependencies: ["PlotModel", "SpelledPitch"]),

        // Tests
        .testTarget(name: "PlotModelTests", dependencies: ["PlotModel"]),
        .testTarget(name: "SpelledPitchTests", dependencies: ["SpelledPitch"]),
        .testTarget(name: "SpelledRhythmTests", dependencies: ["SpelledRhythm"]),
        .testTarget(name: "StaffModelTests", dependencies: ["StaffModel"])
    ]
)
