//
//  ConnectivityConfiguration.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityConfiguration

public extension NetworkConnectivityKit {
    struct ConnectivityConfiguration: Sendable {
        public let urlSession: URLSession

        public init(urlSession: URLSession) {
            self.urlSession = urlSession
        }

        public init(urlSessionConfig: URLSessionConfiguration) {
            self.init(urlSession: URLSession(configuration: urlSessionConfig))
        }

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

        /// Default configuration for URLSession
        /// Using 3 seconds timeout and ignore cache
        public static let `default` = ConnectivityConfiguration()
    }
}

// MARK: - CachePolicy

public extension NetworkConnectivityKit.ConnectivityConfiguration {
    enum CachePolicy {
        case ignoreCache
        case useCache(policy: URLRequest.CachePolicy, urlCache: URLCache?)
    }
}

// MARK: - Method chaining

public extension NetworkConnectivityKit.ConnectivityConfiguration {
    func timeout(_ timeout: TimeInterval?) -> Self {
        let urlSessionConfig = urlSession.configuration
        urlSessionConfig.setTimeout(timeout)
        return .init(urlSessionConfig: urlSessionConfig)
    }

    func cachePolicy(_ cachePolicy: NetworkConnectivityKit.ConnectivityConfiguration.CachePolicy) -> Self {
        let urlSessionConfig = urlSession.configuration
        urlSessionConfig.setCachePolicy(cachePolicy)
        return .init(urlSessionConfig: urlSessionConfig)
    }

    func ignoreCache() -> Self {
        cachePolicy(.ignoreCache)
    }
}

private extension URLSessionConfiguration {
    func setTimeout(_ timeout: TimeInterval?) {
        if let timeout {
            timeoutIntervalForRequest = timeout
            timeoutIntervalForResource = timeout
        } else {
            timeoutIntervalForRequest = NetworkConnectivityKit.defaultTimeoutIntervalForRequest
            timeoutIntervalForResource = NetworkConnectivityKit.defaultTimeoutIntervalForResource
        }
    }

    func setCachePolicy(_ policy: NetworkConnectivityKit.ConnectivityConfiguration.CachePolicy) {
        switch policy {
            case .ignoreCache:
                requestCachePolicy = .reloadIgnoringCacheData
                urlCache = nil
            case .useCache(let policy, let urlCache):
                requestCachePolicy = policy
                self.urlCache = urlCache
        }
    }

    func setAllowsCellularAccess(_ allowsCellularAccess: Bool) {
        self.allowsCellularAccess = allowsCellularAccess
    }
}

private extension NetworkConnectivityKit {
    /// Default timeout interval of URLSession, Apple doc:
    /// https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1408259-timeoutintervalforrequest
    /// https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1408153-timeoutintervalforresource
    static let defaultTimeoutIntervalForRequest: TimeInterval = 60.0
    static let defaultTimeoutIntervalForResource: TimeInterval = 7 * 24 * 60 * 60.0
}
