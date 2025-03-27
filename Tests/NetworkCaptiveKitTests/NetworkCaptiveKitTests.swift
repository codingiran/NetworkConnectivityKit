@testable import NetworkConnectivityKit
import XCTest

final class NetworkConnectivityKitTests: XCTestCase {
    func testSingle() async throws {
        guard let vivo: NetworkConnectivityKit.ConnectivityMethod = .vivoWifi else {
            return
        }
        let result = await NetworkConnectivityKit.checkConnectivity(using: vivo)
        debugPrint(result)
    }

    func testMulti() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .default)
        debugPrint(result)
    }

    func testAllDefault() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .allDefault)
        debugPrint(result)
    }

    func testCustom1() async throws {
        guard let customMethod = NetworkConnectivityKit.ConnectivityMethod(urlString: "http://www.v2ex.com/generate_204", validation: .generate204Validation) else {
            return
        }
        let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
        debugPrint(result)
    }

    func testCustom2() async throws {
        guard let customMethod = NetworkConnectivityKit.ConnectivityMethod(urlString: "http://connectivitycheck.platform.hicloud.com/generate_204", validation: .validation { request, response, data in
            debugPrint("url: \(request.url?.absoluteString ?? ""), response: \(response.statusCode), data: \(data)")
            return response.statusCode == 204
        }) else {
            return
        }
        let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
        debugPrint(result)
    }

    func testCustom3() async throws {
        // custom timeout and cache
        guard let customMethod = NetworkConnectivityKit.ConnectivityMethod(urlString: "http://www.v2ex.com/generate_204",
                                                                           validation: .generate204Validation,
                                                                           configuration: .default.timeout(1.0).ignoreCache())
        else {
            return
        }
        let result = await NetworkConnectivityKit.checkConnectivity(using: customMethod)
        debugPrint(result)
    }
}
