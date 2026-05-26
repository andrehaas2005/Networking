import XCTest
@testable import Networking
@testable import Core

final class NetworkClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    func testGetSuccess() async throws {

        let json = """
        { "url": "https://example.com" }
        """.data(using: .utf8)!

        MockURLProtocol.mockResponse = (json, 200)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let sut = NetworkClient(
            baseURL: URL(string: "https://test.com")!,
            session: session
        )

        let result: UrlResponse = try await sut.get("/api/alias/123")

        XCTAssertEqual(result.url, "https://example.com")
    }

    func testHttpError() async {
        MockURLProtocol.mockResponse = ("{}".data(using: .utf8)!, 404)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let sut = NetworkClient(
            baseURL: URL(string: "https://test.com")!,
            session: session
        )

        do {
            let _: UrlResponse = try await sut.get("/api/alias/123")
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpError(404))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
