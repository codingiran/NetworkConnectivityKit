@testable import NetworkConnectivityKit
import XCTest

final class NetworkConnectivityKitTests: XCTestCase {
    func testSingle() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .googleGstatic)
        debugPrint(result)
    }

    func testMulti() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: [.appleCaptive, .googleGstatic, .vivoWifi])
        debugPrint(result)
    }

    func testCustom() async throws {
        let result = await NetworkConnectivityKit.checkConnectivity(using: .custom(url: "http://www.v2ex.com/generate_204", validation: .generate204Validation))
        debugPrint(result)

        let result2 = await NetworkConnectivityKit.checkConnectivity(using: .custom(url: "http://connectivitycheck.platform.hicloud.com/generate_204", validation: .validation { url, response, data in
            debugPrint("url: \(url), response: \(response), data: \(data)")
            return true
        }))
    }
}
