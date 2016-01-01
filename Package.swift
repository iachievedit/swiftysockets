import PackageDescription

let package = Package(
  name:  "swiftysockets",
  dependencies: [
    .Package(url:  "../Tide", majorVersion: 0),
  ]
)
