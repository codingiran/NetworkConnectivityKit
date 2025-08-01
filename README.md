# NetworkConnectivityKit

[![Swift Version](https://img.shields.io/badge/swift-5.10%2B-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com/swift/)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

NetworkConnectivityKit is a modern, lightweight Swift library for testing real network connectivity on Apple platforms. Unlike simple reachability checks, this library performs actual HTTP requests to well-known endpoints to determine if internet connectivity is truly available.

## Why NetworkConnectivityKit?

Traditional reachability APIs only check if a network interface is available, but they can't detect:

- Captive portals (like hotel or airport WiFi login pages)
- Restricted networks with limited internet access
- Network configurations that block specific traffic

NetworkConnectivityKit solves these problems by making real HTTP requests to reliable endpoints and validating the responses, giving you confidence that your app can actually reach the internet.

> **Need monitor system network reachability and information?**
Check out [NetworkPathMonitor](https://github.com/codingiran/NetworkPathMonitor) - A modern, type-safe, network path monitoring utility for Apple platforms using Swift Concurrency.

## Requirements

- Swift 5.10+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+

## Installation

### Swift Package Manager

Add NetworkConnectivityKit to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iranqiu/NetworkConnectivityKit.git", from: "1.1.0")
]
```

Then import the module:

```swift
import NetworkConnectivityKit
```

## Quick Start

### Basic Connectivity Check

The simplest way to check connectivity:

```swift
import NetworkConnectivityKit

// Check connectivity using default endpoints
let isConnected = await NetworkConnectivityKit.checkConnectivity()

if isConnected {
    print("Internet is available")
} else {
    print("No internet connectivity")
}
```

### Single Endpoint Testing

Test connectivity against a specific endpoint:

```swift
// Test using Apple's captive portal endpoint
let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .appleCaptive)

// Test using Google's generate_204 endpoint
let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .googleGstatic)
```

## Advanced Usage

### Testing Multiple Endpoints

Test multiple endpoints concurrently for better reliability:

```swift
// Use predefined endpoint sets
let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .allDefault)

// Or create a custom set (no optional handling needed!)
let methods: Set<NetworkConnectivityKit.ConnectivityMethod> = [
    .appleCaptive,
    .googleGstatic,
    .cloudflare
]

let isConnected = await NetworkConnectivityKit.checkConnectivity(using: methods)
```

### Custom Endpoints

Create your own connectivity test endpoints with compile-time or runtime URL validation:

```swift
// Compile-time safe StaticString URLs (recommended for hardcoded URLs)
let staticMethod = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "http://www.gstatic.com/generate_204",
    validation: .generate204Validation
)

// Runtime URL validation (for dynamic URLs)
let dynamicMethod = NetworkConnectivityKit.ConnectivityMethod(
    urlString: "https://api.example.com/health",
    validation: .generate200Validation
)

// Complex custom validation
let advancedValidation = NetworkConnectivityKit.ConnectivityValidation { request, response, data in
    response.statusCode == 200 && data.count > 10
}

let advancedMethod = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "https://api.example.com/ping",
    validation: advancedValidation
)

// All methods can be used directly
let result1 = await NetworkConnectivityKit.checkConnectivity(using: staticMethod)
let result2 = await NetworkConnectivityKit.checkConnectivity(using: dynamicMethod!)
let result3 = await NetworkConnectivityKit.checkConnectivity(using: advancedMethod)
```

### Configuration Options

Customize timeout, caching, and other network settings:

```swift
// Create custom configuration
let config = NetworkConnectivityKit.ConnectivityConfiguration(
    timeout: 5.0,                    // 5 second timeout
    cachePolicy: .ignoreCache,       // Always make fresh requests
    allowsCellularAccess: true       // Allow cellular connections
)

// Create method with custom configuration (StaticString version)
let method = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "https://api.example.com/check",
    validation: .generate200Validation,
    configuration: config
)

// Or use fluent configuration
let fluentConfig = NetworkConnectivityKit.ConnectivityConfiguration.default
    .timeout(10.0)
    .ignoreCache()

let isConnected = await NetworkConnectivityKit.checkConnectivity(using: method)
```

## Built-in Endpoints

NetworkConnectivityKit includes several well-tested endpoints (all non-optional and compile-time safe):

| Endpoint | URL | Expected Response | Description |
|----------|-----|-------------------|-------------|
| `.appleCaptive` | `http://captive.apple.com` | HTTP 200 | Apple's captive portal detection |
| `.appleLibrary` | `http://www.apple.com/library/test/success.html` | HTTP 200 | Apple's connectivity test page |
| `.googleGstatic` | `http://www.gstatic.com/generate_204` | HTTP 204 | Google's lightweight endpoint |
| `.cloudflare` | `http://cp.cloudflare.com/generate_204` | HTTP 204 | Cloudflare's connectivity check |
| `.microsoft` | `http://www.msftconnecttest.com/connecttest.txt` | HTTP 200 | Microsoft's connectivity test |
| `.vivoWifi` | `http://wifi.vivo.com.cn/generate_204` | HTTP 204 | Vivo WiFi connectivity check |
| `.miuiConnect` | `http://connect.rom.miui.com/generate_204` | HTTP 204 | MIUI connectivity check |

## Performance

NetworkConnectivityKit is designed for minimal performance impact:

- **Lightweight requests**: Uses minimal HTTP requests (usually < 1KB)
- **Concurrent execution**: Multiple endpoints tested simultaneously
- **Quick timeouts**: Default 3-second timeout for fast results
- **Early termination**: Stops as soon as connectivity is confirmed
- **No persistent connections**: Each test is independent
- **Compile-time optimization**: StaticString URLs eliminate runtime URL parsing overhead

## License

NetworkConnectivityKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Support

- 📧 Email: <codingiran@gmail.com>
- 🐦 Twitter: [@codingiran](https://x.com/Iran_Qiu)