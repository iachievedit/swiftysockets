import PackageDescription

let package = Package(
  name:  "swiftysockets",
  dependencies: [
    .Package(url:  "https://github.com/iachievedit/Tide", majorVersion: 0),
    .Package(url:  "https://github.com/jabwd/Swift-Libevent", majorVersion: 0)
  ]
)
