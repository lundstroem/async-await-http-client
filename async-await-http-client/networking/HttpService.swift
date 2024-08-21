//
//  HttpClient.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

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
    /* add more content-types if needed */
    case unspecified = "application/octet-stream"
    case json = "application/json"
    case pdf = "application/pdf"
}

struct ResponseContent {
    var urlString: String
    var statusCode: Int
    var data: Data?
}

struct AuthHeader {
    let key: String
    let value: String
}

@MainActor
class HttpService {

    /* Change useMock flag here to switch between mock and remote */
    static let shared: HttpService = HttpService(useMock: true)

    let baseUrl: String = "http://127.0.0.1:7043/"

    private let useMock: Bool
    private let debugPrintEnabled: Bool = true

    func makeRequest(urlString: String,
                     httpMethod: HttpMethod = .get,
                     httpBody: Data? = nil,
                     mockResponseStatusCode: Int? = nil,
                     contentType: ContentType) async throws -> ResponseContent {

        /* Add auth method, api keys and anything else depending on REST API setup */

        let responseContent: ResponseContent = try await makeRequestInternal(urlString: urlString,
                                                                             httpMethod: httpMethod,
                                                                             httpBody: httpBody,
                                                                             authHeader: nil,
                                                                             mockResponseStatusCode: mockResponseStatusCode,
                                                                             contentType: contentType)

        return responseContent
    }

    init(useMock: Bool) {
        self.useMock = useMock
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
}

// MARK: - Internal

private extension HttpService {

    func makeRequestInternal(urlString: String,
                             httpMethod: HttpMethod = .get,
                             httpBody: Data? = nil,
                             authHeader: AuthHeader? = nil,
                             mockResponseStatusCode: Int? = nil,
                             contentType: ContentType) async throws -> ResponseContent {

        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        var request = URLRequest(url: url)
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

        if let authHeader = authHeader {
            request.setValue(authHeader.value, forHTTPHeaderField: authHeader.key)
        }

        request.httpMethod = httpMethod.rawValue

        if let httpBody = httpBody {
            request.httpBody = httpBody
        }

        let (data, response) = try await loadData(request: request, mockResponseStatusCode: mockResponseStatusCode)

        guard let response = response as? HTTPURLResponse else {
            throw FetchError.noValidResponse
        }

        if debugPrintEnabled {
            printStatusCode(response: response, urlString: urlString)
        }

        return ResponseContent(urlString: response.url?.absoluteString ?? "", statusCode: response.statusCode, data: data)
    }
}

// MARK: - URLSession extension

extension URLSession {

    /*
     To get around the warning: "Passing argument of non-sendable type '(any URLSessionTaskDelegate)?'
     outside of main actor-isolated context may introduce data races" when using Strict Concurrency Checking Complete:

     The warning is talking about the delegate parameter of data(from:delegate:). This parameter has a default value (nil)
     so it is still passed, even if you are not passing anything explicitly.

     The Task is running in a main actor-isolated context, but data(from:delegate:) is not isolated to the main actor,
     hence you are passing the delegate from a main actor-isolated context, to a non-isolated context. "Outside of main
     actor-isolated context" as the warning says.

     So you should call data(from:delegate:) from a non-isolated context in the first place. A simple way to do that is
     to create a wrapper of data(from:delegate) which does not have a delegate parameter.

     extension URLSession {
         func data(from url: URL) async throws -> (Data, URLResponse) {
             // this call is in a non-isolated context, so all is good :)
             try await URLSession.shared.data(from: url, delegate: nil)
         }
     }

     After that, the call in your Task { ... } will automatically resolve to the overload above. You are still calling a
     non-isolated function from a main actor-isolated context, but this time, you are no longer passing a URLSessionTaskDelegate
     (and URL is Sendable), so there are no warnings.

     Side note: in a View, consider using the task and task(id:) modifiers instead of creating a top level Task { ... }. These
     modifiers cancels the task automatically when the view disappears.

     https://stackoverflow.com/questions/78763125/passing-argument-of-non-sendable-type-any-urlsessiontaskdelegate-outside-of
     */

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request, delegate: nil)
    }
}

// MARK: - Mock

private extension HttpService {

    func loadData(request: URLRequest, 
                  mockResponseStatusCode: Int? = nil) async throws -> (Data?, URLResponse?) {
        if useMock {
            let (data, response) = try await loadMock(request: request,
                                                      mockResponseStatusCode: mockResponseStatusCode)
            return (data, response)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        return (data, response)
    }

    func loadMock(request: URLRequest, 
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

        /* add more mockable types if needed */

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

        print("Parsing content received from: \(responseContent.urlString)")
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
