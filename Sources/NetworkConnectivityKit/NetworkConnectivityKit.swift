//
//  NetworkConnectivityKit.swift
//  NetworkConnectivityKit
//
//  Created by iran.qiu on 2024/11/14.
//

import Foundation

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.10)
    #error("NetworkConnectivityKit doesn't support Swift versions below 5.10.")
#endif

/// Current NetworkConnectivityKit version 1.1.0. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "1.1.0"

// MARK: - NetworkConnectivityKit Namespace

/// A lightweight Swift library for testing network connectivity using multiple validation methods.
///
/// NetworkConnectivityKit provides a reliable way to check internet connectivity by attempting
/// connections to various well-known endpoints. It supports concurrent testing of multiple
/// endpoints and returns as soon as any connection succeeds.
public enum NetworkConnectivityKit: Sendable {}

// MARK: - Connectivity Public API

public extension NetworkConnectivityKit {
    /// Tests network connectivity using multiple methods concurrently.
    ///
    /// This method attempts to connect to multiple endpoints simultaneously and returns `true`
    /// as soon as any connection succeeds. Remaining requests are automatically cancelled
    /// to minimize resource usage.
    ///
    /// - Parameter methods: A set of connectivity methods to test. Defaults to a curated
    ///   selection including Apple Captive Portal, Google's generate_204, and Vivo WiFi endpoints.
    /// - Returns: `true` if any of the methods successfully establishes connectivity, `false` otherwise.
    ///
    /// ## Example
    /// ```swift
    /// // Test connectivity using default methods
    /// let isConnected = await NetworkConnectivityKit.checkConnectivity()
    ///
    /// // Test connectivity using custom methods
    /// let methods: Set<ConnectivityMethod> = [.appleCaptive, .googleGstatic]
    /// let isConnected = await NetworkConnectivityKit.checkConnectivity(using: methods)
    /// ```
    static func checkConnectivity(using methods: Set<NetworkConnectivityKit.ConnectivityMethod> = .default) async -> Bool {
        guard !methods.isEmpty else {
            return false
        }
        if methods.count == 1, let method = methods.first {
            return await checkConnectivity(using: method)
        }
        // Initiate multiple requests concurrently, return true if one succeeds, and cancel the other Tasks.
        return await withTaskGroup(of: Bool.self) { group in
            for method in methods {
                group.addTask {
                    await checkConnectivity(using: method)
                }
            }
            for await value in group {
                if value {
                    // Return as soon as 1 succeeds, cancel if there are other requests
                    group.cancelAll()
                    return true
                }
            }
            return false
        }
    }

    /// Tests network connectivity using a single method.
    ///
    /// This method performs a connectivity check against a single endpoint with the
    /// specified validation criteria.
    ///
    /// - Parameter method: The connectivity method to test. Each method defines an endpoint
    ///   URL, validation logic, and configuration settings.
    /// - Returns: `true` if the method successfully establishes connectivity, `false` otherwise.
    ///
    /// ## Example
    /// ```swift
    /// // Test connectivity using Apple's captive portal
    /// let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .appleCaptive)
    ///
    /// // Test connectivity using Google's generate_204 endpoint
    /// let isConnected = await NetworkConnectivityKit.checkConnectivity(using: .googleGstatic)
    /// ```
    static func checkConnectivity(using method: NetworkConnectivityKit.ConnectivityMethod) async -> Bool {
        let success = await method.performRequest()
        return success
    }
}

// MARK: - Default Method

public extension Set where Element == NetworkConnectivityKit.ConnectivityMethod {
    /// Default set of connectivity methods for general use.
    ///
    /// This set includes a carefully selected collection of reliable endpoints:
    /// - Apple Captive Portal: Apple's own connectivity check endpoint
    /// - Google Gstatic: Google's lightweight generate_204 endpoint
    /// - Vivo WiFi: Vivo's connectivity check endpoint
    ///
    /// These methods provide good coverage across different network environments
    /// and geographical regions.
    static let `default`: Set<NetworkConnectivityKit.ConnectivityMethod> = [
        .appleCaptive,
        .googleGstatic,
        .vivoWifi,
    ]

    /// Comprehensive set of all built-in connectivity methods.
    ///
    /// This set includes all available built-in endpoints for maximum coverage:
    /// - Apple Captive Portal and Library endpoints
    /// - Google Gstatic generate_204 endpoint
    /// - Cloudflare connectivity check
    /// - Microsoft connectivity test
    /// - MIUI Connect endpoint
    /// - Vivo WiFi endpoint
    ///
    /// Use this when you need the most comprehensive connectivity testing,
    /// though it may result in more network requests.
    static let allDefault: Set<NetworkConnectivityKit.ConnectivityMethod> = [
        .appleCaptive,
        .appleLibrary,
        .googleGstatic,
        .cloudflare,
        .microsoft,
        .miuiConnect,
        .vivoWifi,
    ]
}
