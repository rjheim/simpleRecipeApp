// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RecipeFeature",
    platforms: [
        .iOS("16.0"),
        .macOS("14"),
        .visionOS("1.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RecipeFeature",
            targets: ["RecipeFeature"]
        ),
        .library(
            name: "RecipeInterface",
            targets: ["RecipeInterface"]
        ),
        .library(
            name: "RecipeModels",
            targets: ["RecipeModels"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RecipeFeature",
            dependencies: ["RecipeInterface"]
        ),
        .testTarget(
            name: "RecipeFeatureTests",
            dependencies: ["RecipeFeature"]
        ),
        .target(
            name: "RecipeInterface"
        ),
        .target(
            name: "RecipeModels",
            dependencies: ["RecipeInterface"]
        ),
        .testTarget(
            name: "RecipeModelsTests",
            dependencies: ["RecipeModels"],
            resources: [.process("testRecipes.json")]
        ),
    ]
)
