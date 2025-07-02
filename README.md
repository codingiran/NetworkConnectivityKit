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

## Features

✅ **Real connectivity testing** - Makes actual HTTP requests, not just interface checks  
✅ **Concurrent testing** - Tests multiple endpoints simultaneously for faster results  
✅ **Captive portal detection** - Identifies networks that require authentication  
✅ **Customizable validation** - Define your own endpoints and validation logic  
✅ **Built-in endpoint collection** - Includes endpoints from Apple, Google, Cloudflare, and more  
✅ **Swift concurrency** - Full async/await support with structured concurrency  
✅ **Minimal overhead** - Lightweight requests with configurable timeouts  
✅ **Cross-platform** - Works on iOS, macOS, tvOS, watchOS, and visionOS  
✅ **Compile-time safety** - StaticString URLs for guaranteed valid endpoints  
✅ **Type-safe API** - Non-optional built-in methods eliminate runtime errors

## Requirements

- Swift 5.10+ (Swift 6.0+ for latest features)
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

#### Swift Version Compatibility

NetworkConnectivityKit supports multiple Swift versions:

- **Swift 5.10+**: Fully supported with all features
- **Swift 6.0+**: Enhanced with strict concurrency checking and latest language features

The package automatically selects the appropriate configuration based on your project's Swift version.

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

## API Design & Type Safety

### StaticString vs String URLs

NetworkConnectivityKit provides two ways to create connectivity methods:

```swift
// ✅ StaticString (Recommended for hardcoded URLs)
// - Compile-time validation
// - Non-optional result  
// - Crashes early if URL is invalid (fail-fast principle)
let method1 = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "http://www.gstatic.com/generate_204",
    validation: .generate204Validation
)

// ✅ String (For dynamic URLs)
// - Runtime validation
// - Optional result (returns nil for invalid URLs)
// - Graceful handling of invalid URLs
let method2 = NetworkConnectivityKit.ConnectivityMethod(
    urlString: userProvidedURL,
    validation: .generate200Validation
)
```

### Built-in Methods Are Non-Optional

```swift
// ❌ Old pattern (no longer needed)
guard let method = NetworkConnectivityKit.ConnectivityMethod.appleCaptive else {
    // Handle nil case
    return
}
let result = await NetworkConnectivityKit.checkConnectivity(using: method)

// ✅ New pattern (direct usage)
let result = await NetworkConnectivityKit.checkConnectivity(using: .appleCaptive)
```

## How It Works

1. **Concurrent Requests**: When testing multiple endpoints, NetworkConnectivityKit makes requests concurrently
2. **Early Success**: Returns `true` as soon as any endpoint responds successfully
3. **Automatic Cancellation**: Cancels remaining requests once success is detected
4. **Validation Logic**: Each endpoint has specific validation rules (status codes, content checks)
5. **Timeout Protection**: Configurable timeouts prevent hanging requests
6. **Cache Avoidance**: Ignores cached responses by default for accurate real-time results
7. **Compile-time Safety**: StaticString URLs ensure built-in endpoints are always valid

## Error Handling

NetworkConnectivityKit handles network errors gracefully:

```swift
// The method returns false for any network errors, timeouts, or validation failures
let isConnected = await NetworkConnectivityKit.checkConnectivity()

// For custom error handling, you can create your own validation logic
let customValidation = NetworkConnectivityKit.ConnectivityValidation { request, response, data in
    // Custom logic here - return false to indicate connectivity failure
    guard response.statusCode == 200 else { return false }
    // Additional checks...
    return true
}

// StaticString version for compile-time safety
let safeMethod = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "https://api.example.com/health",
    validation: customValidation
)
```

## Best Practices

### Performance Optimization

```swift
// Use default endpoints for general connectivity testing
let isConnected = await NetworkConnectivityKit.checkConnectivity()

// For faster results, test fewer endpoints
let quickCheck = await NetworkConnectivityKit.checkConnectivity(using: [.googleGstatic])

// For maximum reliability, use all endpoints
let reliableCheck = await NetworkConnectivityKit.checkConnectivity(using: .allDefault)
```

### App Integration

```swift
class ConnectivityManager {
    func checkConnectivity() async -> Bool {
        await NetworkConnectivityKit.checkConnectivity()
    }
    
    func performNetworkOperation() async throws {
        guard await checkConnectivity() else {
            throw NetworkError.noConnectivity
        }
        
        // Proceed with network operation
    }
    
    // Use StaticString for compile-time safety with known URLs
    func checkSpecificEndpoint() async -> Bool {
        let customMethod = NetworkConnectivityKit.ConnectivityMethod(
            staticURLString: "https://api.myapp.com/health",
            validation: .generate200Validation
        )
        
        return await NetworkConnectivityKit.checkConnectivity(using: customMethod)
    }
}
```

### URL Safety Guidelines

```swift
// ✅ Use StaticString for known, hardcoded URLs
let staticMethod = NetworkConnectivityKit.ConnectivityMethod(
    staticURLString: "http://www.gstatic.com/generate_204",
    validation: .generate204Validation
)

// ✅ Use String initializer for user input or dynamic URLs
func createMethodFromUserInput(_ url: String) -> NetworkConnectivityKit.ConnectivityMethod? {
    return NetworkConnectivityKit.ConnectivityMethod(
        urlString: url,
        validation: .generate200Validation
    )
}

// ✅ Built-in methods are always safe to use directly
let result = await NetworkConnectivityKit.checkConnectivity(using: .appleCaptive)
```

## Sample Projects

Check out the [Examples](Examples/) directory for complete sample projects showing:

- Basic connectivity checking
- Custom endpoint configuration
- Integration with SwiftUI
- Background connectivity monitoring
- StaticString vs String URL usage patterns

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

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

## Credits

Created and maintained by [CodingIran](https://github.com/iranqiu).

## Support

- 📧 Email: <codingiran@gmail.com>
- 🐛 Issues: [GitHub Issues](https://github.com/iranqiu/NetworkConnectivityKit/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/iranqiu/NetworkConnectivityKit/discussions)
