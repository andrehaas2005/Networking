import XCTest
@testable import Networking
@testable import Core

struct ResultCallBack: Codable {
let url: String
}

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
    
    MockURLProtocol().mockResponse = ResponseCallback(data: json, statusCode: 200)
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    
    let sut = NetworkClient(
      baseURL: URL(string: "https://test.com")!,
      session: session
    )
    
    sut.get("/api/alias/123") { [weak self] (result: Result<ResultCallBack,NetworkError>) in
      switch result {
      case .success(let success):
        XCTAssertEqual(success.url, "https://example.com")
      case .failure(let failure):
        XCTFail("Expected error")
      }
    }
  }

  func testHttpError() async {
    MockURLProtocol().mockResponse = ResponseCallback(data: "{}".data(using: .utf8)!, statusCode: 404)
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    
    let sut = NetworkClient(
      baseURL: URL(string: "https://test.com")!,
      session: session
    )
    
    
    sut.get("/api/alias/123") { [weak self] (result: Result<ResultCallBack, NetworkError>) in
      switch result {
      case .success:
        XCTFail("Expected error")
      case .failure(let error):
        XCTAssertEqual(error, .httpError(404))
      }
    }
  }
}
