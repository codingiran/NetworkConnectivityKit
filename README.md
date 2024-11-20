# NetworkConnectivityKit

NetworkConnectivityKit is a lightweight Swift library for testing network connectivity using multiple validation methods. It provides a reliable way to check internet connectivity by attempting connections to various well-known endpoints.

## Requirements

- Swift 5.9+
- iOS/macOS/tvOS/watchOS/visionOS

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:


```swift
dependencies: [
    .package(url: "https://github.com/iranqiu/NetworkConnectivityKit.git", from: "0.0.1")
]
```

## Features

- Multiple connectivity testing methods
- Concurrent connectivity checks
- Customizable validation endpoints
- Built-in support for common connectivity check endpoints:
  - Apple Captive Portal
  - Apple Library
  - Google Generate_204
  - Cloudflare
  - Vivo WiFi
  - MIUI Connect
- Custom endpoint support with configurable validation

## Usage

### Basic Usage

```swift
import NetworkConnectivityKit
// Test connectivity using the default method (Apple Captive)
let isConnected = await NetworkConnectivityKit.checkConnectivity()
// Test connectivity using a specific method
let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .googleGstatic)
```

### Testing Multiple Methods Concurrently

```swift
// Test multiple endpoints concurrently
let methods: Set<NetworkConnectivityKit.ConnectivityMethod> = [
    .appleCaptive,
    .googleGstatic,
    .cloudflare
]

let isConnected = await NetworkConnectivityKit.checkConnectivity(using: methods)
```

### Custom Endpoint

```swift
// Create a custom endpoint with specific validation
let customValidation = NetworkConnectivityKit.ConnectivityValidation { url, response, data in
    response.statusCode == 200
}

let customMethod = NetworkConnectivityKit.ConnectivityMethod.custom(
    url: "https://your-endpoint.com/check",
    validation: customValidation
)

let isConnected = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
```

## How It Works

NetworkConnectivityKit attempts to connect to specified endpoints and validates the responses. The library:

- Uses lightweight HTTP requests
- Implements concurrent checking
- Ignores cache data
- Has a 3-second timeout for quick results
- Cancels remaining requests once a successful connection is established

## License

MIT

## Author

iran.qiu@gmail.com
