//
//  ConnectivityMethod.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityMethod

public extension NetworkConnectivityKit {
    struct ConnectivityMethod: Sendable {
        public let urlRequest: URLRequest
        public let validation: ConnectivityValidation
        public let configuration: ConnectivityConfiguration

        public init(urlRequest: URLRequest, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            self.urlRequest = urlRequest
            self.validation = validation
            self.configuration = configuration
        }

        public init(url: URL, validation: ConnectivityValidation, configuration: ConnectivityConfiguration = .default) {
            self.init(urlRequest: URLRequest(url: url, configuration: configuration), validation: validation, configuration: configuration)
        }

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
    static let appleCaptive = Self(urlString: "http://captive.apple.com", validation: .generate200Validation)

    static let appleLibrary = Self(urlString: "http://www.apple.com/library/test/success.html", validation: .generate200Validation)

    static let googleGstatic = Self(urlString: "http://www.gstatic.com/generate_204", validation: .generate204Validation)

    static let cloudflare = Self(urlString: "http://cp.cloudflare.com/generate_204", validation: .generate204Validation)

    static let microsoft = Self(urlString: "http://www.msftconnecttest.com/connecttest.txt", validation: .generate200Validation)

    static let vivoWifi = Self(urlString: "http://wifi.vivo.com.cn/generate_204", validation: .generate204Validation)

    static let miuiConnect = Self(urlString: "http://connect.rom.miui.com/generate_204", validation: .generate204Validation)
}

// MARK: - Perform Request

extension NetworkConnectivityKit.ConnectivityMethod {
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
