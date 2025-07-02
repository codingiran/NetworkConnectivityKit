//
//  ConnectivityConfiguration.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityConfiguration

public extension NetworkConnectivityKit {
    /// Configuration settings for network connectivity testing.
    ///
    /// This struct encapsulates URLSession configuration options specifically optimized
    /// for connectivity testing scenarios. It provides sensible defaults for timeout,
    /// caching behavior, and cellular access that work well for quick connectivity checks.
    ///
    /// ## Example
    /// ```swift
    /// // Use default configuration (3s timeout, ignore cache)
    /// let config = ConnectivityConfiguration.default
    ///
    /// // Create custom configuration
    /// let customConfig = ConnectivityConfiguration(
    ///     timeout: 5.0,
    ///     cachePolicy: .ignoreCache,
    ///     allowsCellularAccess: true
    /// )
    /// ```
    struct ConnectivityConfiguration: Sendable {
        /// The underlying URLSession used for network requests.
        public let urlSession: URLSession

        /// Creates a configuration with an existing URLSession.
        ///
        /// - Parameter urlSession: The URLSession to use for connectivity testing
        public init(urlSession: URLSession) {
            self.urlSession = urlSession
        }

        /// Creates a configuration with a URLSessionConfiguration.
        ///
        /// - Parameter urlSessionConfig: The URLSessionConfiguration to use
        public init(urlSessionConfig: URLSessionConfiguration) {
            self.init(urlSession: URLSession(configuration: urlSessionConfig))
        }

        /// Creates a configuration with specific timeout and caching settings.
        ///
        /// This is the most commonly used initializer, providing fine-grained control
        /// over the key parameters that affect connectivity testing performance.
        ///
        /// - Parameters:
        ///   - timeout: Request timeout in seconds. Defaults to 3 seconds for quick results.
        ///     Use `nil` to apply system default timeouts.
        ///   - cachePolicy: Caching strategy for requests. Defaults to `.ignoreCache` for
        ///     accurate connectivity testing.
        ///   - allowsCellularAccess: Whether to allow requests over cellular connections.
        ///     Defaults to `true`.
        public init(timeout: TimeInterval? = 3,
                    cachePolicy: ConnectivityConfiguration.CachePolicy = .ignoreCache,
                    allowsCellularAccess: Bool = true)
        {
            let config = URLSessionConfiguration.default
            config.setTimeout(timeout)
            config.setCachePolicy(cachePolicy)
            config.setAllowsCellularAccess(allowsCellularAccess)
            self.init(urlSessionConfig: config)
        }

        /// Default configuration optimized for connectivity testing.
        ///
        /// This configuration uses:
        /// - 3-second timeout for quick results
        /// - Cache ignored to ensure fresh connectivity tests
        /// - Cellular access allowed for comprehensive testing
        public static let `default` = ConnectivityConfiguration()
    }
}

// MARK: - CachePolicy

public extension NetworkConnectivityKit.ConnectivityConfiguration {
    /// Caching policies for connectivity testing requests.
    ///
    /// Different caching strategies affect how fresh the connectivity test results are.
    /// For most connectivity testing scenarios, ignoring cache provides the most
    /// accurate real-time connectivity status.
    enum CachePolicy {
        /// Ignores all cached responses and always makes fresh network requests.
        ///
        /// This is the recommended policy for connectivity testing as it ensures
        /// you're testing actual network connectivity rather than cached responses.
        case ignoreCache

        /// Uses a custom caching policy with optional URLCache.
        ///
        /// - Parameters:
        ///   - policy: The URLRequest cache policy to use
        ///   - urlCache: Optional custom URLCache instance, or `nil` to use default
        case useCache(policy: URLRequest.CachePolicy, urlCache: URLCache?)
    }
}

// MARK: - Method chaining

public extension NetworkConnectivityKit.ConnectivityConfiguration {
    /// Returns a new configuration with the specified timeout.
    ///
    /// This method follows a fluent interface pattern, allowing you to chain
    /// configuration modifications.
    ///
    /// - Parameter timeout: The new timeout value in seconds, or `nil` for system defaults
    /// - Returns: A new configuration instance with the updated timeout
    ///
    /// ## Example
    /// ```swift
    /// let config = ConnectivityConfiguration.default
    ///     .timeout(5.0)
    ///     .ignoreCache()
    /// ```
    func timeout(_ timeout: TimeInterval?) -> Self {
        let urlSessionConfig = urlSession.configuration
        urlSessionConfig.setTimeout(timeout)
        return .init(urlSessionConfig: urlSessionConfig)
    }

    /// Returns a new configuration with the specified cache policy.
    ///
    /// - Parameter cachePolicy: The cache policy to use for requests
    /// - Returns: A new configuration instance with the updated cache policy
    func cachePolicy(_ cachePolicy: NetworkConnectivityKit.ConnectivityConfiguration.CachePolicy) -> Self {
        let urlSessionConfig = urlSession.configuration
        urlSessionConfig.setCachePolicy(cachePolicy)
        return .init(urlSessionConfig: urlSessionConfig)
    }

    /// Returns a new configuration that ignores cache.
    ///
    /// This is a convenience method equivalent to `.cachePolicy(.ignoreCache)`.
    ///
    /// - Returns: A new configuration instance that ignores cache
    func ignoreCache() -> Self {
        cachePolicy(.ignoreCache)
    }
}

private extension URLSessionConfiguration {
    /// Sets timeout intervals for requests and resources.
    ///
    /// - Parameter timeout: The timeout interval in seconds, or `nil` for defaults
    func setTimeout(_ timeout: TimeInterval?) {
        if let timeout {
            timeoutIntervalForRequest = timeout
            timeoutIntervalForResource = timeout
        } else {
            timeoutIntervalForRequest = NetworkConnectivityKit.defaultTimeoutIntervalForRequest
            timeoutIntervalForResource = NetworkConnectivityKit.defaultTimeoutIntervalForResource
        }
    }

    /// Configures the caching policy for the session.
    ///
    /// - Parameter policy: The cache policy to apply
    func setCachePolicy(_ policy: NetworkConnectivityKit.ConnectivityConfiguration.CachePolicy) {
        switch policy {
        case .ignoreCache:
            requestCachePolicy = .reloadIgnoringCacheData
            urlCache = nil
        case let .useCache(policy, urlCache):
            requestCachePolicy = policy
            self.urlCache = urlCache
        }
    }

    /// Sets whether cellular access is allowed for requests.
    ///
    /// - Parameter allowsCellularAccess: Whether to allow cellular connections
    func setAllowsCellularAccess(_ allowsCellularAccess: Bool) {
        self.allowsCellularAccess = allowsCellularAccess
    }
}

private extension NetworkConnectivityKit {
    /// Default timeout interval for URLSession requests.
    ///
    /// Based on Apple's documentation for NSURLSessionConfiguration.timeoutIntervalForRequest:
    /// https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1408259-timeoutintervalforrequest
    static let defaultTimeoutIntervalForRequest: TimeInterval = 60.0

    /// Default timeout interval for URLSession resources.
    ///
    /// Based on Apple's documentation for NSURLSessionConfiguration.timeoutIntervalForResource:
    /// https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1408153-timeoutintervalforresource
    static let defaultTimeoutIntervalForResource: TimeInterval = 7 * 24 * 60 * 60.0
}
