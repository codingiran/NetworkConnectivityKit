//
//  ConnectivityValidation.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityValidation

public extension NetworkConnectivityKit {
    /// Defines validation logic for determining successful network connectivity from HTTP responses.
    ///
    /// A connectivity validation encapsulates the logic needed to interpret whether an HTTP
    /// response indicates successful network connectivity. Different endpoints use different
    /// response patterns (status codes, content, etc.) to signal connectivity.
    ///
    /// ## Example
    /// ```swift
    /// // Create custom validation for a specific status code
    /// let validation = ConnectivityValidation(statusCode: 200)
    ///
    /// // Create custom validation with complex logic
    /// let customValidation = ConnectivityValidation { request, response, data in
    ///     response.statusCode == 200 && data.count > 0
    /// }
    /// ```
    struct ConnectivityValidation: Sendable {
        /// A closure that validates an HTTP response for connectivity determination.
        ///
        /// - Parameters:
        ///   - request: The original URL request that was sent
        ///   - response: The HTTP response received from the server
        ///   - data: The response body data
        /// - Returns: `true` if the response indicates successful connectivity, `false` otherwise
        public typealias Validation = @Sendable (URLRequest, HTTPURLResponse, Data) -> Bool

        /// The validation closure used to determine connectivity success.
        let validation: Validation

        /// Creates a connectivity validation with custom logic.
        ///
        /// - Parameter validation: A closure that determines connectivity success based on
        ///   the URL request, HTTP response, and response data
        public init(validation: @escaping Validation) {
            self.validation = validation
        }

        /// Creates a connectivity validation that checks for a specific HTTP status code.
        ///
        /// This is a convenience initializer for simple status code-based validation,
        /// which is the most common pattern for connectivity endpoints.
        ///
        /// - Parameter statusCode: The expected HTTP status code for successful connectivity
        public init(statusCode: Int) {
            self.init { _, response, _ in
                response.statusCode == statusCode
            }
        }

        /// Creates a connectivity validation with custom logic.
        ///
        /// This is a convenience method that provides the same functionality as the initializer
        /// but with a more descriptive name for clarity.
        ///
        /// - Parameter validation: A closure that determines connectivity success
        /// - Returns: A new connectivity validation instance
        public static func validation(_ validation: @escaping Validation) -> Self {
            ConnectivityValidation(validation: validation)
        }

        /// Standard validation for endpoints that return HTTP 204 (No Content).
        ///
        /// Many connectivity check endpoints (like Google's generate_204) return a
        /// 204 status code with no content body to indicate successful connectivity.
        /// This validation is optimized for such endpoints.
        public static let generate204Validation = ConnectivityValidation(statusCode: 204)

        /// Standard validation for endpoints that return HTTP 200 (OK).
        ///
        /// Traditional connectivity check endpoints return a 200 status code with
        /// content to indicate successful connectivity. This validation checks for
        /// the 200 status code regardless of response content.
        public static let generate200Validation = ConnectivityValidation(statusCode: 200)
    }
}
