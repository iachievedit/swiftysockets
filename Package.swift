import PackageDescription

let package = Package(
  name:  "swiftysockets",
  dependencies: [
    .Package(url:  "https://github.com/iachievedit/Tide", majorVersion: 0),
  ]
)
