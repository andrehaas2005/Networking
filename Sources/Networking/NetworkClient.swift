import Foundation
import Core

public final class NetworkClient: NetworkClientProtocol {

    private let baseURL: URL
    private let session: URLSession

    public init(
        baseURL: URL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func post<T: Decodable, U: Encodable>(
        _ path: String,
        body: U,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {

        do {

            let bodyData = try JSONEncoder().encode(body)

            let request = try URLRequestBuilder.build(
                baseURL: baseURL,
                path: path,
                method: "POST",
                body: bodyData
            )

            execute(request, completion: completion)

        } catch {
            completion(.failure(.unknown))
        }
    }

    public func get<T: Decodable>(
        _ path: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {

        do {

            let request = try URLRequestBuilder.build(
                baseURL: baseURL,
                path: path,
                method: "GET"
            )

            execute(request, completion: completion)

        } catch {
            completion(.failure(.unknown))
        }
    }

    private func execute<T: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {

        session.dataTask(with: request) { data, response, error in

            if let error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let data else {
                completion(.failure(.unknown))
                return
            }

            do {

                try self.validate(response)

                let decoded = try JSONDecoder().decode(T.self, from: data)

                completion(.success(decoded))

            } catch let networkError as NetworkError {

                completion(.failure(networkError))

            } catch {

                completion(.failure(.decodingFailed(error)))
            }

        }.resume()
    }

    private func validate(_ response: URLResponse?) throws {

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.httpError(http.statusCode)
        }
    }
}
