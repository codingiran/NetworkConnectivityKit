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
    /// Test connectivity using multiple methods.
    /// - Parameter methods: Set of ConnectivityMethod. Default is `appleCaptive`, `googleGstatic`, `vivoWifi`.
    /// - Returns: `true` if any of the methods succeeds, `false` otherwise.
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

    /// Test connectivity using a single method.
    /// - Parameter method: ConnectivityMethod. Default is `appleCaptive`.
    /// - Returns: `true` if the method succeeds, `false` otherwise.
    static func checkConnectivity(using method: NetworkConnectivityKit.ConnectivityMethod) async -> Bool {
        let success = await method.performRequest()
        return success
    }
}

// MARK: - Default Method

public extension Set where Element == NetworkConnectivityKit.ConnectivityMethod {
    static let `default`: Set<NetworkConnectivityKit.ConnectivityMethod> = Set([.appleCaptive,
                                                                                .googleGstatic,
                                                                                .vivoWifi].compactMap { $0 })

    static let allDefault: Set<NetworkConnectivityKit.ConnectivityMethod> = Set([.appleCaptive,
                                                                                 .appleLibrary,
                                                                                 .googleGstatic,
                                                                                 .cloudflare,
                                                                                 .microsoft,
                                                                                 .miuiConnect,
                                                                                 .vivoWifi].compactMap { $0 })
}
