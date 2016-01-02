# swiftysockets
Socket Implementation in Swift

swiftysockets is a socket implementation in Swift built upon the work done by the Zewo TCPIP module.

To use swiftysockets in your application you'll need to first install [`libtide.a`](https://github.com/iachievedit/Tide).  Once `libtide.a` and its headers are installed on your system you can use swiftysockets in your project with a Swift Package Manager `Package` dependency:

```
import PackageDescription

let package = Package(
  name:  "chatterserver",
  dependencies: [
    .Package(url:  "https://github.com/iachievedit/swiftysockets", majorVersion: 0),
  ]
)
```
