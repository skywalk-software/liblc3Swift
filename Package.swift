// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "liblc3",
    products: [
        // This is the product that can be imported by other packages
        .library(name: "liblc3", targets: ["liblc3Swift"]),
    ],
    targets: [
        .target(
           name: "liblc3C",
           dependencies: [],
           exclude: [
               "CONTRIBUTING.md",
               "LICENSE",
               "Makefile",
               "README.md",
               "conformance",
               "fuzz",
               "meson.build",
               "meson_options.txt",
               "pyproject.toml",
               "python",
               "tables",
               "test",
               "tools",
               "wasm",
               "zephyr",
               "src/meson.build",
               "src/makefile.mk"
           ],
           sources: [
               "src"
           ],
           publicHeadersPath: "include",
           cSettings: [
               .headerSearchPath("include"),
               .headerSearchPath("src")
           ]
         ),
        .target(
            name: "liblc3Swift",
            dependencies: ["liblc3C"],
            path: "Sources/liblc3Swift"
        ),
    ]
)
