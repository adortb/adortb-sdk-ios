import Foundation

final class HTTPClient {
    private let session: URLSession
    private let timeout: TimeInterval

    init(timeout: TimeInterval = 3.0) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        self.session = URLSession(configuration: config)
        self.timeout = timeout
    }

    func post<T: Encodable, R: Decodable>(
        url: URL,
        body: T,
        responseType: R.Type,
        completion: @escaping (Result<R, Error>) -> Void
    ) {
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(body)
        } catch {
            completion(.failure(AdError.encodingError(error)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        session.dataTask(with: request) { responseData, response, error in
            if let error = error {
                completion(.failure(AdError.networkError(error)))
                return
            }

            guard let responseData = responseData else {
                completion(.failure(AdError.invalidResponse))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(R.self, from: responseData)
                completion(.success(decoded))
            } catch {
                completion(.failure(AdError.invalidResponse))
            }
        }.resume()
    }

    func upload(url: URL, body: Data) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        session.uploadTask(with: request, from: body) { _, _, _ in }.resume()
    }
}
