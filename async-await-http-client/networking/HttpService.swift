/*

 MIT License

 Copyright (c) 2024 Harry Lundström

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

import Foundation

enum FetchError: Error {
    case noValidResponse
}

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

enum ContentType: String {
    // add more content-types if needed
    case unspecified = "application/octet-stream"
    case json = "application/json"
    case pdf = "application/pdf"
}

struct ResponseContent {
    let urlRequest: URLRequest?
    let response: HTTPURLResponse?
    var data: Data?
}

struct AuthHeader {
    let key: String
    let value: String
}

class HttpService {

    let scheme = "https"
    let host = "go-examples-433707.ew.r.appspot.com"
    let port = 8080
    let useSpecificPort: Bool = false

    init(mockEnabled: Bool = false) {
        self.mockEnabled = mockEnabled
    }

    var baseUrl: String {
        useSpecificPort ? "\(scheme)://\(host):\(port)" : "\(scheme)://\(host)"
    }

    private let globalMockEnabled: Bool = true
    private let debugPrintEnabled: Bool = true
    private let mockEnabled: Bool

    func makeRequest(path: String,
                     httpMethod: HttpMethod = .get,
                     httpBody: Data? = nil,
                     urlQueryItems: [URLQueryItem] = [],
                     contentType: ContentType,
                     mockResponseStatusCode: Int? = nil) async throws -> ResponseContent {

        // Add auth method, api keys and anything else depending on REST API setup

        let responseContent: ResponseContent = try await makeRequestInternal(path: path,
                                                                             httpMethod: httpMethod,
                                                                             httpBody: httpBody,
                                                                             urlQueryItems: urlQueryItems,
                                                                             authHeader: nil,
                                                                             contentType: contentType,
                                                                             mockResponseStatusCode: mockResponseStatusCode)

        return responseContent
    }

    func decodeResponseData<T: Decodable>(decodable: T.Type,
                                          responseContent: ResponseContent) async throws -> T {
        guard let data = responseContent.data else {
            throw FetchError.noValidResponse
        }

        if debugPrintEnabled {
            parseDebug(responseType: T.self,
                       responseContent: responseContent)
        }

        let decodedResponse: T = try JSONDecoder().decode(T.self, from: data)
        return decodedResponse
    }

    func loadData(request: URLRequest,
                  mockResponseStatusCode: Int? = nil) async throws -> (Data?, URLResponse?) {

        if globalMockEnabled || mockEnabled {
            let (data, response) = try await loadMock(request: request,
                                                      mockResponseStatusCode: mockResponseStatusCode)
            return (data, response)
        } else {
            let (data, response) = try await URLSession.shared.data(for: request)
            return (data, response)
        }
    }
}

// MARK: - Internal

private extension HttpService {

    func makeUrlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if useSpecificPort {
            components.port = port
        }
        return components
    }

    func makeRequestInternal(path: String,
                             httpMethod: HttpMethod = .get,
                             httpBody: Data? = nil,
                             urlQueryItems: [URLQueryItem] = [],
                             authHeader: AuthHeader? = nil,
                             contentType: ContentType,
                             mockResponseStatusCode: Int? = nil) async throws -> ResponseContent {

        var urlComponents: URLComponents = makeUrlComponents()
        urlComponents.path = path
        if (!urlQueryItems.isEmpty) {
            urlComponents.queryItems = urlQueryItems
        }

        guard let url = urlComponents.url else { fatalError("Missing URL") }

        var request = URLRequest(url: url)
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

        if let authHeader = authHeader {
            request.setValue(authHeader.value, forHTTPHeaderField: authHeader.key)
        }

        request.httpMethod = httpMethod.rawValue

        if let httpBody = httpBody {
            request.httpBody = httpBody
        }

        let (data, response) = try await loadData(request: request,
                                                  mockResponseStatusCode: mockResponseStatusCode)

        guard let response = response as? HTTPURLResponse else {
            throw FetchError.noValidResponse
        }

        if debugPrintEnabled {
            printStatusCode(response: response, urlString: url.absoluteString)
        }

        return ResponseContent(urlRequest: request,
                               response: response,
                               data: data)
    }

    private func loadMock(request: URLRequest,
                          mockResponseStatusCode: Int? = nil) async throws -> (Data?, URLResponse?) {
        var statusCode = 200
        if let mockResponseStatusCode = mockResponseStatusCode {
            statusCode = mockResponseStatusCode
        }

        let contentType = request.value(forHTTPHeaderField: "Content-Type")
        var fileEnding = "json"

        if (contentType == "application/pdf") {
            fileEnding = "pdf"
        }

        // add more mockable types if needed

        if let url = request.url {
            var filePath = url.absoluteString
            filePath.trimPrefix(baseUrl)
            filePath = "mock/" + filePath

            let fileName = "\(statusCode)-\(request.httpMethod ?? "")"

            if let data = Utils.loadResourceFromBundle(name: fileName, fileEnding: fileEnding, filePath: filePath),
               let url = URL(string: filePath) {

                let urlResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "", headerFields: [:])
                return (data, urlResponse)
            }
        }

        return (nil, nil)
    }
}

// MARK: - Debug prints

private extension HttpService {

    func printStatusCode(response: HTTPURLResponse, urlString: String) {
        if response.statusCode >= 400  {
            let errorString = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            let error = NSError(domain: "", code: response.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Server responded with status: \(response.statusCode) (\(errorString)) for url: \(response.url?.absoluteString ?? "")"
            ])
            print("\(error.localizedDescription)")
        } else {
            print("Server responded with status: \(response.statusCode) for url: \(response.url?.absoluteString ?? "")")
        }
    }

    func prettyPrintedJSONString(_ data: Data) -> NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }

    /// Used in debug for identifying JSON parsing issues
    func parseDebug<T: Decodable>(responseType: T.Type, responseContent: ResponseContent) {
        guard let data = responseContent.data else { return }

        print("Parsing content received from: \(responseContent.response?.url?.absoluteString ?? "")")
        print("\(prettyPrintedJSONString(data) ?? "(error: cannot parse response)")")

        do {
            let _ = try JSONDecoder().decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
}
