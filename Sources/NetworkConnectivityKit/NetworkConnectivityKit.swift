//
//  NetworkConnectivityKit.swift
//  NetworkConnectivityKit
//
//  Created by iran.qiu on 2024/11/14.
//

import Foundation

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.9)
#error("NetworkConnectivityKit doesn't support Swift versions below 5.9.")
#endif

/// Current NetworkConnectivityKit version 0.0.2. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.2"

public enum NetworkConnectivityKit: Sendable {}

public extension NetworkConnectivityKit {
    /// Test connectivity using multiple methods.
    /// - Parameter methods: Set of ConnectivityMethod. Default is `appleCaptive`, `googleGstatic`, `vivoWifi`.
    /// - Returns: `true` if any of the methods succeeds, `false` otherwise.
    static func checkConnectivity(using methods: Set<ConnectivityMethod> = [.appleCaptive, .googleGstatic, .vivoWifi]) async -> Bool {
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
    static func checkConnectivity(using method: ConnectivityMethod) async -> Bool {
        let success = await method.performRequest()
        return success
    }
}

// MARK: - ConnectivityValidation

public extension NetworkConnectivityKit {
    struct ConnectivityValidation: Sendable {
        public typealias Validation = @Sendable (URL, HTTPURLResponse, Data) -> Bool

        let validation: Validation

        public init(validation: @escaping Validation) {
            self.validation = validation
        }

        public init(statusCode: Int) {
            self.init { _, response, _ in
                response.statusCode == statusCode
            }
        }

        public static func validation(_ validation: @escaping Validation) -> Self {
            ConnectivityValidation(validation: validation)
        }

        public static let generate204Validation = ConnectivityValidation(statusCode: 204)

        public static let generate200Validation = ConnectivityValidation(statusCode: 200)
    }
}

// MARK: - ConnectivityMethod

public extension NetworkConnectivityKit {
    enum ConnectivityMethod: Sendable {
        case appleCaptive
        case appleLibrary
        case googleGstatic
        case cloudflare
        case vivoWifi
        case miuiConnect
        case custom(url: String, validation: ConnectivityValidation)
    }
}

extension NetworkConnectivityKit.ConnectivityMethod {
    var urlString: String {
        switch self {
        case .appleCaptive:
            return "http://captive.apple.com"
        case .appleLibrary:
            return "http://www.apple.com/library/test/success.html"
        case .googleGstatic:
            return "http://www.gstatic.com/generate_204"
        case .cloudflare:
            return "http://cp.cloudflare.com/generate_204"
        case .vivoWifi:
            return "http://wifi.vivo.com.cn/generate_204"
        case .miuiConnect:
            return "http://connect.rom.miui.com/generate_204"
        case .custom(let url, _):
            return url
        }
    }

    func performRequest() async -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        do {
            let response = try await defaultURLSession.data(from: url)
            guard let httpResponse = response.1 as? HTTPURLResponse else {
                return false
            }
            let statusCode = httpResponse.statusCode
            switch self {
            case .appleCaptive, .appleLibrary:
                return statusCode == 200
            case .googleGstatic, .cloudflare, .vivoWifi, .miuiConnect:
                return statusCode == 204
            case .custom(_, let validation):
                return validation.validation(url, httpResponse, response.0)
            }
        } catch {
            return false
        }
    }

    var defaultURLSession: URLSession { URLSession(configuration: Self.defaultURLSessionConfiguration) }

    static var defaultURLSessionConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 3
        return config
    }
}

extension NetworkConnectivityKit.ConnectivityMethod: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(urlString)
    }

    public static func == (lhs: NetworkConnectivityKit.ConnectivityMethod, rhs: NetworkConnectivityKit.ConnectivityMethod) -> Bool {
        lhs.urlString == rhs.urlString
    }
}
