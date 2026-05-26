import Foundation

public struct URLRequestBuilder {

    public static func build(
        baseURL: URL,
        path: String,
        method: String,
        body: Data? = nil
    ) throws -> URLRequest {

        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }

        return request
    }
}
