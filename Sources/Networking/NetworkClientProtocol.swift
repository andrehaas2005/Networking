import Foundation

public protocol NetworkClientProtocol {
  func post<T: Decodable, U: Encodable>(
      _ path: String,
      body: U,
      completion: @escaping (Result<T, NetworkError>) -> Void
  )
  
  func get<T: Decodable>(
      _ path: String,
      completion: @escaping (Result<T, NetworkError>) -> Void
  ) 
}
