import Foundation

public struct Courier {
    // properties
    private var apiUrl: String
    private var session = URLSession(configuration: defaultConfiguration())

    // init
    init(url: String, session: URLSession? = nil) {
        guard url.hasSuffix("/")
        else {
            preconditionFailure("API_URL must end in /")
        }

        self.apiUrl = url
        if let session = session {
            self.session = session
        }
    }

    // functions
    func get<T: Codable>(
        path: String,
        headers: [String: String] = [:],
        queries: [String: Any] = [:],
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request = newRequest(pathifyQueries(path, queries), headers)
        request.httpMethod = "GET"

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, error)
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    func post<T: Codable>(
        path: String,
        headers: [String: String] = [:],
        body: Data,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request = newRequest(path, headers)
        request.httpMethod = "POST"
        request.httpBody = body

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, error)
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    func post<T: Codable>(
        path: String,
        headers: [String: String] = [:],
        form: MultipartFormDataRequest,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request = newMultipartRequest(path, form.boundary, headers)
        request.httpMethod = "POST"
        request.httpBody = form.getBody()

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, error)
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    func patch<T: Codable>(
        path: String,
        headers: [String: String] = [:],
        body: Data,
        completion: @escaping (T?, Error?) -> Void
    ) {
        func handleCompletion(_ result: T?, _ error: Error?) {
            DispatchQueue.main.async {
                completion(result, error)
            }
        }

        var request = newRequest(path, headers)
        request.httpMethod = "PATCH"
        request.httpBody = body

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(nil, error)
                }
            }

            guard error == nil, let data = data, !data.isEmpty
            else {
                return handleCompletion(nil, error)
            }

            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                handleCompletion(result, nil)
            } catch let e {
                handleCompletion(nil, e)
            }
        }
        .resume()
    }

    func delete(
        path: String,
        headers: [String: String] = [:],
        completion: @escaping (Error?) -> Void
    ) {
        func handleCompletion(_ error: Error?) {
            DispatchQueue.main.async {
                completion(error)
            }
        }

        var request = newRequest(path, headers)
        request.httpMethod = "DELETE"

        session.dataTask(with: request) { (data, res, error) in
            if let httpRes = res as? HTTPURLResponse {
                guard (200...299).contains(httpRes.statusCode)
                else {
                    return handleCompletion(error)
                }
            }

            handleCompletion(error)
        }
        .resume()
    }

    private func newRequest(
        _ path: String,
        _ headers: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: apiUrl + path)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }

    private func newMultipartRequest(
        _ path: String,
        _ boundary: String,
        _ headers: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: apiUrl + path)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }

    private func pathifyQueries(_ path: String, _ queries: [String: Any]) -> String {
        guard !queries.isEmpty
        else {
            return path
        }

        var truePath = path + "?"

        for (index, query) in queries.enumerated() {
            let queryValue = "\(query.value)".replacingOccurrences(of: " ", with: "+")
            truePath += query.key + "=" + queryValue
            if index != queries.count - 1 {
                truePath += "&"
            }
        }

        return truePath
    }

    private static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(30)
        config.timeoutIntervalForResource = TimeInterval(30)
        return config
    }
}
