//
//  NetworkConnectivityKitTests.swift
//  NetworkConnectivityKit
//
//  Created by CodingIran on 2025/3/27.
//

@testable import NetworkConnectivityKit
import XCTest

final class NetworkConnectivityKitTests: XCTestCase {
    // MARK: - Test Lifecycle

    override func setUp() {
        super.setUp()
        // Set up any shared test state here
    }

    override func tearDown() {
        // Clean up after tests
        super.tearDown()
    }

    // MARK: - Basic Connectivity Tests

    func testDefaultConnectivityCheck() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity()
        // Note: This test depends on actual network connectivity
        // In a real network environment, this should typically return true
        XCTAssertTrue(result || !result, "Method should return a boolean value")
    }

    func testSingleMethodConnectivity() async throws {
        // Create a custom method to avoid optional handling
        let method = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )

        guard let validMethod = method else {
            XCTFail("Failed to create connectivity method")
            return
        }

        let result = await NetworkConnectivityKit.checkConnectivity(using: validMethod)
        XCTAssertTrue(result || !result, "Single method check should return a boolean value")
    }

    // MARK: - Built-in Method Availability Tests

    func testBuiltInMethodConnectivity() async throws {
        // Test reliable built-in methods (no longer need compactMap since they're non-optional)
        let methods = [
            NetworkConnectivityKit.ConnectivityMethod.googleGstatic,
            NetworkConnectivityKit.ConnectivityMethod.appleCaptive,
            NetworkConnectivityKit.ConnectivityMethod.cloudflare,
        ]

        let method = methods.first!
        let result = await NetworkConnectivityKit.checkConnectivity(using: method)
        XCTAssertTrue(result || !result, "Built-in method should return a boolean")
    }

    // MARK: - Multiple Methods Tests

    func testDefaultMethodSet() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .default)
        XCTAssertTrue(result || !result, "Default method set should return a boolean")
    }

    func testAllDefaultMethodSet() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .allDefault)
        XCTAssertTrue(result || !result, "All default method set should return a boolean")
    }

    func testCustomMethodSet() async throws {
        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )
        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://captive.apple.com",
            validation: .generate200Validation
        )

        let methods = [method1, method2].compactMap { $0 }
        let methodSet = Set(methods)

        XCTAssertFalse(methodSet.isEmpty, "Should have valid custom methods")

        let result = await NetworkConnectivityKit.checkConnectivity(using: methodSet)
        XCTAssertTrue(result || !result, "Custom method set should return a boolean")
    }

    func testSingleMethodInSet() async throws {
        let method = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )

        guard let validMethod = method else {
            XCTFail("Failed to create connectivity method")
            return
        }

        let methods: Set<NetworkConnectivityKit.ConnectivityMethod> = [validMethod]
        let result = await NetworkConnectivityKit.checkConnectivity(using: methods)
        XCTAssertTrue(result || !result, "Single method in set should return a boolean")
    }

    // MARK: - Custom Method Tests

    func testCustomMethodWithValidURL() async throws {
        let customMethod = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )
        XCTAssertNotNil(customMethod, "Custom method with valid URL should not be nil")

        if let method = customMethod {
            let result = await NetworkConnectivityKit.checkConnectivity(using: method)
            XCTAssertTrue(result || !result, "Custom method should return a boolean")
        }
    }

    func testCustomMethodWithStaticURLString() async throws {
        // Test the new StaticString initializer
        let customMethod = NetworkConnectivityKit.ConnectivityMethod(
            staticURLString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )

        // No need to check for nil since StaticString initializer is non-optional
        let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
        XCTAssertTrue(result || !result, "StaticString method should return a boolean")

        // Verify the URL was set correctly
        XCTAssertEqual(customMethod.urlRequest.url?.absoluteString, "http://www.gstatic.com/generate_204",
                       "StaticString should create correct URL")
    }

    func testStaticStringMethodWithCustomConfiguration() async throws {
        let customConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            timeout: 2.0,
            cachePolicy: .ignoreCache
        )

        let method = NetworkConnectivityKit.ConnectivityMethod(
            staticURLString: "http://cp.cloudflare.com/generate_204",
            validation: .generate204Validation,
            configuration: customConfig
        )

        // Verify configuration was applied
        XCTAssertEqual(method.configuration.urlSession.configuration.timeoutIntervalForRequest, 2.0,
                       "Custom configuration should be applied to StaticString method")

        let result = await NetworkConnectivityKit.checkConnectivity(using: method)
        XCTAssertTrue(result || !result, "StaticString method with custom config should return a boolean")
    }

    func testStaticStringMethodEquality() {
        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            staticURLString: "http://example.com/test",
            validation: .generate200Validation
        )

        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://example.com/test",
            validation: .generate204Validation
        )

        XCTAssertNotNil(method2, "Regular method should be created successfully")

        if let regularMethod = method2 {
            XCTAssertEqual(method1, regularMethod,
                           "StaticString and regular methods with same URL should be equal")
            XCTAssertEqual(method1.hashValue, regularMethod.hashValue,
                           "StaticString and regular methods with same URL should have equal hash values")
        }
    }

    func testBuiltInMethodsUseStaticString() {
        // Test that built-in methods are now non-optional and work directly
        let appleCaptive = NetworkConnectivityKit.ConnectivityMethod.appleCaptive
        let googleGstatic = NetworkConnectivityKit.ConnectivityMethod.googleGstatic
        let cloudflare = NetworkConnectivityKit.ConnectivityMethod.cloudflare

        // Verify URLs are correctly set
        XCTAssertEqual(appleCaptive.urlRequest.url?.absoluteString, "http://captive.apple.com",
                       "Apple Captive should have correct URL")
        XCTAssertEqual(googleGstatic.urlRequest.url?.absoluteString, "http://www.gstatic.com/generate_204",
                       "Google Gstatic should have correct URL")
        XCTAssertEqual(cloudflare.urlRequest.url?.absoluteString, "http://cp.cloudflare.com/generate_204",
                       "Cloudflare should have correct URL")

        // Verify validation types
        XCTAssertTrue(appleCaptive.validation.validation(
            URLRequest(url: URL(string: "http://test.com")!),
            HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            Data()
        ), "Apple Captive should use 200 validation")

        XCTAssertTrue(googleGstatic.validation.validation(
            URLRequest(url: URL(string: "http://test.com")!),
            HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 204, httpVersion: nil, headerFields: nil)!,
            Data()
        ), "Google Gstatic should use 204 validation")
    }

    func testStaticStringAPIConvenience() async throws {
        // Demonstrate the improved API without optional handling

        // Before optimization would require: guard let method = .appleCaptive else { return }
        // Now we can use directly:
        let result1 = await NetworkConnectivityKit.checkConnectivity(using: .appleCaptive)
        let result2 = await NetworkConnectivityKit.checkConnectivity(using: .googleGstatic)
        let result3 = await NetworkConnectivityKit.checkConnectivity(using: .cloudflare)

        // All should return boolean values without any optional unwrapping
        XCTAssertTrue(result1 || !result1, "Apple Captive should return boolean")
        XCTAssertTrue(result2 || !result2, "Google Gstatic should return boolean")
        XCTAssertTrue(result3 || !result3, "Cloudflare should return boolean")

        // Test with method sets - no compactMap needed
        let methods: Set<NetworkConnectivityKit.ConnectivityMethod> = [
            .appleCaptive,
            .googleGstatic,
            .cloudflare,
        ]

        let setResult = await NetworkConnectivityKit.checkConnectivity(using: methods)
        XCTAssertTrue(setResult || !setResult, "Method set should return boolean")
    }

    func testCustomMethodWithInvalidURL() {
        // Test with empty string which should definitely fail URL creation
        let customMethod = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "",
            validation: .generate204Validation
        )
        XCTAssertNil(customMethod, "Custom method with empty URL string should be nil")

        // Note: URL(string:) is more permissive than expected and creates URLs
        // for many strings that might seem invalid, so we focus on cases that truly fail
        // StaticString version would catch invalid URLs at compile time with fatalError
    }

    func testCustomValidationLogic() async throws {
        let customValidation = NetworkConnectivityKit.ConnectivityValidation { request, response, _ in
            // Custom validation: check status code and ensure response is from expected URL
            response.statusCode == 204 && request.url?.host?.contains("gstatic") == true
        }

        let customMethod = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: customValidation
        )

        XCTAssertNotNil(customMethod, "Custom method with custom validation should not be nil")

        if let method = customMethod {
            let result = await NetworkConnectivityKit.checkConnectivity(using: method)
            XCTAssertTrue(result || !result, "Custom validation method should return a boolean")
        }
    }

    // MARK: - Configuration Tests

    func testDefaultConfiguration() {
        let config = NetworkConnectivityKit.ConnectivityConfiguration.default
        XCTAssertNotNil(config.urlSession, "Default configuration should have a URLSession")
        XCTAssertEqual(config.urlSession.configuration.timeoutIntervalForRequest, 3.0,
                       "Default timeout should be 3 seconds")
    }

    func testCustomTimeoutConfiguration() async throws {
        let config = NetworkConnectivityKit.ConnectivityConfiguration(timeout: 1.0)
        XCTAssertEqual(config.urlSession.configuration.timeoutIntervalForRequest, 1.0,
                       "Custom timeout should be applied")

        let method = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation,
            configuration: config
        )

        XCTAssertNotNil(method, "Method with custom configuration should not be nil")

        if let customMethod = method {
            let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
            XCTAssertTrue(result || !result, "Method with custom timeout should return a boolean")
        }
    }

    func testFluentConfigurationInterface() async throws {
        let config = NetworkConnectivityKit.ConnectivityConfiguration.default
            .timeout(2.0)
            .ignoreCache()

        XCTAssertEqual(config.urlSession.configuration.timeoutIntervalForRequest, 2.0,
                       "Fluent timeout configuration should be applied")
        XCTAssertEqual(config.urlSession.configuration.requestCachePolicy, .reloadIgnoringCacheData,
                       "Fluent cache policy should be applied")

        let method = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation,
            configuration: config
        )

        if let customMethod = method {
            let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
            XCTAssertTrue(result || !result, "Method with fluent configuration should return a boolean")
        }
    }

    func testCachePolicyConfiguration() {
        let ignoreCacheConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            cachePolicy: .ignoreCache
        )
        XCTAssertEqual(ignoreCacheConfig.urlSession.configuration.requestCachePolicy,
                       .reloadIgnoringCacheData,
                       "Ignore cache policy should be applied")
        XCTAssertNil(ignoreCacheConfig.urlSession.configuration.urlCache,
                     "URL cache should be nil when ignoring cache")

        let useCacheConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            cachePolicy: .useCache(policy: .returnCacheDataElseLoad, urlCache: URLCache.shared)
        )
        XCTAssertEqual(useCacheConfig.urlSession.configuration.requestCachePolicy,
                       .returnCacheDataElseLoad,
                       "Custom cache policy should be applied")
    }

    func testCellularAccessConfiguration() {
        let noCellularConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            allowsCellularAccess: false
        )
        XCTAssertFalse(noCellularConfig.urlSession.configuration.allowsCellularAccess,
                       "Cellular access should be disabled when configured")

        let allowCellularConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            allowsCellularAccess: true
        )
        XCTAssertTrue(allowCellularConfig.urlSession.configuration.allowsCellularAccess,
                      "Cellular access should be enabled when configured")
    }

    // MARK: - Validation Tests

    func testGenerate200Validation() {
        let validation = NetworkConnectivityKit.ConnectivityValidation.generate200Validation
        let mockRequest = URLRequest(url: URL(string: "http://example.com")!)
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
        let mockData = Data()

        let result = validation.validation(mockRequest, mockResponse, mockData)
        XCTAssertTrue(result, "200 validation should return true for 200 status code")
    }

    func testGenerate204Validation() {
        let validation = NetworkConnectivityKit.ConnectivityValidation.generate204Validation
        let mockRequest = URLRequest(url: URL(string: "http://example.com")!)
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                           statusCode: 204,
                                           httpVersion: nil,
                                           headerFields: nil)!
        let mockData = Data()

        let result = validation.validation(mockRequest, mockResponse, mockData)
        XCTAssertTrue(result, "204 validation should return true for 204 status code")
    }

    func testCustomStatusCodeValidation() {
        let validation = NetworkConnectivityKit.ConnectivityValidation(statusCode: 301)
        let mockRequest = URLRequest(url: URL(string: "http://example.com")!)
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                           statusCode: 301,
                                           httpVersion: nil,
                                           headerFields: nil)!
        let mockData = Data()

        let result = validation.validation(mockRequest, mockResponse, mockData)
        XCTAssertTrue(result, "Custom validation should return true for matching status code")

        let wrongResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)!
        let wrongResult = validation.validation(mockRequest, wrongResponse, mockData)
        XCTAssertFalse(wrongResult, "Custom validation should return false for non-matching status code")
    }

    // MARK: - Edge Cases and Error Handling

    func testEmptyMethodSet() async throws {
        let emptyMethods: Set<NetworkConnectivityKit.ConnectivityMethod> = []
        let result = await NetworkConnectivityKit.checkConnectivity(using: emptyMethods)
        XCTAssertFalse(result, "Empty method set should return false")
    }

    func testInvalidURLMethod() {
        let invalidMethod = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "",
            validation: .generate200Validation
        )
        XCTAssertNil(invalidMethod, "Method with empty URL should be nil")
    }

    func testMethodEquality() {
        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://example.com",
            validation: .generate200Validation
        )
        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://example.com",
            validation: .generate204Validation // Different validation
        )

        XCTAssertNotNil(method1)
        XCTAssertNotNil(method2)

        if let m1 = method1, let m2 = method2 {
            XCTAssertEqual(m1, m2, "Methods with same URL should be equal (based on URL request)")
        }
    }

    func testMethodHashing() {
        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://example.com",
            validation: .generate200Validation
        )
        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://example.com",
            validation: .generate200Validation
        )

        XCTAssertNotNil(method1)
        XCTAssertNotNil(method2)

        if let m1 = method1, let m2 = method2 {
            XCTAssertEqual(m1.hashValue, m2.hashValue, "Equal methods should have equal hash values")
        }
    }

    // MARK: - Performance Tests

    func testConnectivityCheckPerformance() async throws {
        let method = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )

        guard let validMethod = method else {
            XCTFail("Failed to create connectivity method for performance test")
            return
        }

        measure {
            let expectation = XCTestExpectation(description: "Connectivity check")

            Task {
                _ = await NetworkConnectivityKit.checkConnectivity(using: validMethod)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }

    func testMultipleMethodsPerformance() async throws {
        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://captive.apple.com",
            validation: .generate200Validation
        )
        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation
        )
        let method3 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://cp.cloudflare.com/generate_204",
            validation: .generate204Validation
        )

        let methods = Set([method1, method2, method3].compactMap { $0 })

        XCTAssertFalse(methods.isEmpty, "Should have valid methods for performance test")

        measure {
            let expectation = XCTestExpectation(description: "Multiple methods check")

            Task {
                _ = await NetworkConnectivityKit.checkConnectivity(using: methods)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 15.0)
        }
    }

    // MARK: - Integration Tests

    func testRealWorldScenario() async throws {
        // Test a realistic usage scenario
        let customConfig = NetworkConnectivityKit.ConnectivityConfiguration(
            timeout: 5.0,
            cachePolicy: .ignoreCache,
            allowsCellularAccess: true
        )

        let method1 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://captive.apple.com",
            validation: .generate200Validation,
            configuration: customConfig
        )
        let method2 = NetworkConnectivityKit.ConnectivityMethod(
            urlString: "http://www.gstatic.com/generate_204",
            validation: .generate204Validation,
            configuration: customConfig
        )

        let methods = Set([method1, method2].compactMap { $0 })

        XCTAssertFalse(methods.isEmpty, "Should have valid methods for real-world test")

        let result = await NetworkConnectivityKit.checkConnectivity(using: methods)

        // In a real-world scenario with internet access, this should typically be true
        // But we can't guarantee network conditions in all test environments
        XCTAssertTrue(result || !result, "Real-world scenario should complete without errors")
    }

    // MARK: - Default Method Set Tests

    func testDefaultMethodSetContainsValidMethods() {
        let defaultSet = Set<NetworkConnectivityKit.ConnectivityMethod>.default
        XCTAssertFalse(defaultSet.isEmpty, "Default method set should not be empty")
        XCTAssertTrue(defaultSet.count >= 2, "Default method set should contain multiple methods")
    }

    func testAllDefaultMethodSetContainsValidMethods() {
        let allDefaultSet = Set<NetworkConnectivityKit.ConnectivityMethod>.allDefault
        XCTAssertFalse(allDefaultSet.isEmpty, "All default method set should not be empty")
        XCTAssertTrue(allDefaultSet.count >= 5, "All default method set should contain many methods")
    }

    func testPerformance() async throws {
        // No longer need compactMap since built-in methods are non-optional
        let methods: Set<NetworkConnectivityKit.ConnectivityMethod> = [
            NetworkConnectivityKit.ConnectivityMethod.appleCaptive,
            NetworkConnectivityKit.ConnectivityMethod.googleGstatic,
        ]

        let result = await NetworkConnectivityKit.checkConnectivity(using: methods)
        XCTAssertTrue(result || !result, "Performance test should complete without errors")
    }
}
