@testable import TPSwiftSDK
import XCTest

final class TPClientTests: XCTestCase {
    func testPropertyChanges() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        var client = TPClient()
        XCTAssert(client.address == "127.0.0.1", "Address is not equal")
        XCTAssert(client.port == 12136, "Port is not equal")
        client.address = "10.1.10.1"
        client.port = 789456
        XCTAssert(client.address == "10.1.10.1", "Address is not equal")
        XCTAssert(client.port == 789456, "Port is not equal")

        client = TPClient(address: "192.168.1.12", port: 123456)

        XCTAssert(client.address == "192.168.1.12", "Address is not equal")
        XCTAssert(client.port == 123456, "Port is not equal")

        client.address = "10.1.10.143"
        client.port = 723
        XCTAssert(client.address == "10.1.10.143", "Address is not equal")
        XCTAssert(client.port == 723, "Port is not equal")
    }

    func testConnection() {
        

        // do something when connection happens
    }
}
