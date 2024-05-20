# VHDLKripkeStructures

[![Swift Coverage Test](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/cov.yml/badge.svg)](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/cov.yml)
[![Swift Lint](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/swiftlint.yml)
[![Linux CI](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-linux.yml)
[![MacOS CI](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-macOS.yml/badge.svg)](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-macOS.yml)
[![Windows CI](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-windows.yml/badge.svg)](https://github.com/CPSLabGU/VHDLKripkeStructures/actions/workflows/ci-windows.yml)

A `Swift` package for defining Kripke Structures for formally verifying VHDL Logic-Labelled Finite-State
Machines ([LLFSMs](https://github.com/mipalgu/VHDLMachines)).

## Supported Platforms

- Swift version 5.7 or later.
- MacOS 14 or later (earlier versions are likely to work).
- Linux (Ubuntu 22.04) or later.
- Windows 10 or later.
- Windows Server Edition 2022 or later.

## Using this Package

To include this package in your `Swift` projects, place it as a dependency within your package manifest.

```swift
// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: <package name>,
    products: [
        <products>
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/CPSLabGU/VHDLKripkeStructures", from: "1.0.0")
    ],
    targets: [
        <targets>
    ]
)
```
