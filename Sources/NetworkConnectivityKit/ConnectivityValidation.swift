//
//  ConnectivityValidation.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

import Foundation

// MARK: - ConnectivityValidation

public extension NetworkConnectivityKit {
    struct ConnectivityValidation: Sendable {
        public typealias Validation = @Sendable (URLRequest, HTTPURLResponse, Data) -> Bool

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
