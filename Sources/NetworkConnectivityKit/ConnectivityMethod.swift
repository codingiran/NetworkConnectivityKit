//
//  ConnectivityMethod.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityMethod

public extension NetworkConnectivityKit {
    /// Represents a method for testing network connectivity to a specific endpoint.
    ///
    /// A connectivity method encapsulates:
    /// - The target URL request
    /// - Validation logic for determining success
    /// - Configuration settings for the network request
    ///
    /// ## Example
    /// ```swift
    /// // Create a custom connectivity method
    /// let method = ConnectivityMethod(
    ///     url: URL(string: "https://example.com/ping")!,
    ///     validation: .generate200Validation
    /// )
    /// ```
    struct ConnectivityMethod: Sendable {
        /// The URL request to be performed for connectivity testing.
        public let urlRequest: URLRequest

        /// The validation logic used to determine if the response indicates successful connectivity.
        public let validation: ConnectivityValidation

        /// The configuration settings for the underlying URLSession.
        public let configuration: ConnectivityConfiguration

        /// Creates a connectivity method with a custom URL request.
        ///
        /// - Parameters:
        ///   - urlRequest: The URL request to perform
        ///   - validation: The validation logic for the response
        ///   - configuration: The URLSession configuration (defaults to `.default`)
        public init(urlRequest: URLRequest, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            self.urlRequest = urlRequest
            self.validation = validation
            self.configuration = configuration
        }

        /// Creates a connectivity method with a URL.
        ///
        /// - Parameters:
        ///   - url: The target URL for connectivity testing
        ///   - validation: The validation logic for the response
        ///   - configuration: The URLSession configuration (defaults to `.default`)
        public init(url: URL, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            self.init(urlRequest: URLRequest(url: url, configuration: configuration), validation: validation, configuration: configuration)
        }

        /// Creates a connectivity method with a static URL string.
        ///
        /// This initializer is designed for compile-time URL strings that are guaranteed to be valid.
        /// It provides better safety and eliminates the need for optional handling when working with
        /// hardcoded URLs like built-in connectivity endpoints.
        ///
        /// - Parameters:
        ///   - staticURLString: The static URL string for connectivity testing (must be valid at compile time)
        ///   - validation: The validation logic for the response
        ///   - configuration: The URLSession configuration (defaults to `.default`)
        ///
        /// ## Example
        /// ```swift
        /// let method = ConnectivityMethod(
        ///     staticURLString: "http://www.gstatic.com/generate_204",
        ///     validation: .generate204Validation
        /// )
        /// ```
        public init(staticURLString: StaticString, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            let url = URL(staticString: staticURLString)
            self.init(url: url, validation: validation, configuration: configuration)
        }

        /// Creates a connectivity method with a URL string.
        ///
        /// - Parameters:
        ///   - urlString: The target URL string for connectivity testing
        ///   - validation: The validation logic for the response
        ///   - configuration: The URLSession configuration (defaults to `.default`)
        /// - Returns: A new connectivity method, or `nil` if the URL string is invalid
        public init?(urlString: String, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            guard let url = URL(string: urlString) else {
                return nil
            }
            self.init(url: url, validation: validation, configuration: configuration)
        }
    }
}

// MARK: - Built-in ConnectivityMethod

// refer: https://en.wikipedia.org/wiki/Captive_portal

public extension NetworkConnectivityKit.ConnectivityMethod {
    /// Apple's captive portal detection endpoint.
    ///
    /// This endpoint is used by Apple devices to detect captive portals and network connectivity.
    /// It expects a 200 status code with specific content for successful connectivity.
    ///
    /// **URL**: `http://captive.apple.com`
    /// **Expected Response**: HTTP 200 with "Success" content
    static let appleCaptive = Self(staticURLString: "http://captive.apple.com", validation: .generate200Validation)

    /// Apple's library test endpoint for connectivity verification.
    ///
    /// This is an alternative Apple endpoint that provides a reliable connectivity test
    /// with a simple success page response.
    ///
    /// **URL**: `http://www.apple.com/library/test/success.html`
    /// **Expected Response**: HTTP 200 status code
    static let appleLibrary = Self(staticURLString: "http://www.apple.com/library/test/success.html", validation: .generate200Validation)

    /// Google's lightweight connectivity check endpoint.
    ///
    /// This endpoint returns a 204 (No Content) status code for successful connectivity
    /// and is widely used for network connectivity testing due to its minimal response size.
    ///
    /// **URL**: `http://www.gstatic.com/generate_204`
    /// **Expected Response**: HTTP 204 (No Content)
    static let googleGstatic = Self(staticURLString: "http://www.gstatic.com/generate_204", validation: .generate204Validation)

    /// Cloudflare's connectivity check endpoint.
    ///
    /// Cloudflare provides this endpoint specifically for captive portal detection
    /// and connectivity verification with a 204 response.
    ///
    /// **URL**: `http://cp.cloudflare.com/generate_204`
    /// **Expected Response**: HTTP 204 (No Content)
    static let cloudflare = Self(staticURLString: "http://cp.cloudflare.com/generate_204", validation: .generate204Validation)

    /// Microsoft's connectivity test endpoint.
    ///
    /// This endpoint is used by Microsoft systems for network connectivity verification
    /// and returns a simple text response.
    ///
    /// **URL**: `http://www.msftconnecttest.com/connecttest.txt`
    /// **Expected Response**: HTTP 200 status code
    static let microsoft = Self(staticURLString: "http://www.msftconnecttest.com/connecttest.txt", validation: .generate200Validation)

    /// Vivo WiFi connectivity check endpoint.
    ///
    /// This endpoint is commonly used in networks with Vivo devices and provides
    /// reliable connectivity testing in those environments.
    ///
    /// **URL**: `http://wifi.vivo.com.cn/generate_204`
    /// **Expected Response**: HTTP 204 (No Content)
    static let vivoWifi = Self(staticURLString: "http://wifi.vivo.com.cn/generate_204", validation: .generate204Validation)

    /// MIUI (Xiaomi) connectivity check endpoint.
    ///
    /// This endpoint is used by MIUI systems for network connectivity verification
    /// and captive portal detection.
    ///
    /// **URL**: `http://connect.rom.miui.com/generate_204`
    /// **Expected Response**: HTTP 204 (No Content)
    static let miuiConnect = Self(staticURLString: "http://connect.rom.miui.com/generate_204", validation: .generate204Validation)
}

// MARK: - Perform Request

extension NetworkConnectivityKit.ConnectivityMethod {
    /// Performs the connectivity check request and validates the response.
    ///
    /// This method executes the network request using the configured URLSession
    /// and applies the validation logic to determine connectivity success.
    ///
    /// - Returns: `true` if the request succeeds and passes validation, `false` otherwise
    func performRequest() async -> Bool {
        do {
            let response = try await configuration.urlSession.data(for: urlRequest)
            guard let httpResponse = response.1 as? HTTPURLResponse else {
                return false
            }
            return validation.validation(urlRequest, httpResponse, response.0)
        } catch {
            return false
        }
    }
}

// MARK: - Hashable & Equatable

extension NetworkConnectivityKit.ConnectivityMethod: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(urlRequest)
    }

    public static func == (lhs: NetworkConnectivityKit.ConnectivityMethod, rhs: NetworkConnectivityKit.ConnectivityMethod) -> Bool {
        lhs.urlRequest == rhs.urlRequest
    }
}

// MARK: - URLRequest Extension

private extension URLRequest {
    init(url: URL, configuration: NetworkConnectivityKit.ConnectivityConfiguration) {
        let configuration = configuration.urlSession.configuration
        var request = URLRequest(url: url,
                                 cachePolicy: configuration.requestCachePolicy,
                                 timeoutInterval: configuration.timeoutIntervalForRequest)
        request.allowsCellularAccess = configuration.allowsCellularAccess
        self = request
    }
}

// MARK: - URL Extension for StaticString

extension URL {
    /// Creates a URL from a static string, providing compile-time safety for hardcoded URLs.
    ///
    /// This initializer is designed for cases where the URL string is known at compile time
    /// and should always be valid. If the static string cannot be converted to a valid URL,
    /// the application will terminate with a fatal error, helping catch invalid URLs early.
    ///
    /// - Parameter staticString: A static string containing a valid URL
    init(staticString: StaticString) {
        guard let url = Self(string: "\(staticString)") else {
            fatalError("Invalid static URL string: \(staticString)")
        }
        self = url
    }
}
