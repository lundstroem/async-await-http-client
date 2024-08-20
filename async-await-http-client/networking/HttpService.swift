//
//  HttpClient.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

// TODO: Need to check nullability for all response parameters. (Check API docs).
// TODO: Check if JWT should be included in standard, or if any other auth should be default.

enum FetchError: Error {
    case noValidResponse
    case wrongStatusCode(_ statusCode: Int)
    case missingToken
    case useMockIsActivated
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

class HttpService {

    static var shared: HttpService = HttpService()

    private let useMock: Bool = true
    let baseUrl: String = "http://192.168.0.1:7043/"
    private let debugPrintEnabled: Bool = true

    private let endpointLogin: String = "Login"
    private var jsonWebToken: String?

    private let apiKey: String = ""
    private let apiValue: String = ""

    func makeRequest(urlString: String,
                     httpMethod: HttpMethod = .get,
                     httpBody: Data? = nil,
                     contentType: ContentType) async throws -> ResponseContent {

        /*
        guard !useMock else {
            print("App is using mocked data.")
            throw FetchError.useMockIsActivated
        }*/

        /*
        if apiKey.isEmpty && apiValue.isEmpty {
            print("Need to set apiKey and apiValue to enable requests to middleware.")
        }

        if jsonWebToken == nil {
            try await fetchToken()
        }

        guard let jsonWebToken = jsonWebToken else {
            throw FetchError.missingToken
        }

         */
        let authHeader = AuthHeader(key: "Authorization", value: "Bearer \(jsonWebToken ?? "")")


        let responseContent: ResponseContent = try await makeRequestInternal(urlString: urlString,
                                                                             httpMethod: httpMethod,
                                                                             httpBody: httpBody,
                                                                             authHeader: authHeader,
                                                                             contentType: contentType)

        if responseContent.statusCode == 401 {
            // Token has expired, fetch a new one and retry the original request.

            self.jsonWebToken = nil
            try await fetchToken()

            let responseContent: ResponseContent = try await makeRequestInternal(urlString: urlString,
                                                                                 httpMethod: httpMethod,
                                                                                 httpBody: httpBody,
                                                                                 authHeader: authHeader,
                                                                                 contentType: contentType)
            return responseContent

        } else {
            return responseContent
        }
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

    func fetchToken() async throws {
        let responseContent: ResponseContent = try await makeRequestInternal(urlString: baseUrl+endpointLogin,
                                                                             httpMethod: .post,
                                                                             authHeader: AuthHeader(key: apiKey, value: apiValue),
                                                                             contentType: .json)
        if let data = responseContent.data,
           let token = String(data: data, encoding: .utf8) {
            self.jsonWebToken = token.replacingOccurrences(of: "\"", with: "")
        }
    }

    func makeRequestInternal(urlString: String,
                             httpMethod: HttpMethod = .get,
                             httpBody: Data? = nil,
                             authHeader: AuthHeader? = nil,
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

        let (data, response) = try await loadData(request: request)

        guard let response = response as? HTTPURLResponse else {
            throw FetchError.noValidResponse
        }

        if debugPrintEnabled {
            printStatusCode(response: response, urlString: urlString)
        }

        return ResponseContent(urlString: response.url?.absoluteString ?? "", statusCode: response.statusCode, data: data)
    }
}

// MARK: - Mock

private extension HttpService {

    func loadData(request: URLRequest, mockResponseStatusCode: Int? = nil) async throws -> (Data?, URLResponse?) {

        if useMock {
            let (data, response) = try await loadMock(request: request, mockResponseStatusCode: mockResponseStatusCode)
            return (data, response)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        return (data, response)
    }

    func loadMock(request: URLRequest, mockResponseStatusCode: Int? = nil) async throws -> (Data?, URLResponse?) {

        var statusCode = 200
        if let mockResponseStatusCode = mockResponseStatusCode {
            statusCode = mockResponseStatusCode
        }

        if let url = request.url {

            var filePath = url.absoluteString
            filePath.trimPrefix(baseUrl)
            filePath = "mock/" + filePath

            let fileName = "\(statusCode)-\(request.httpMethod ?? "")"

            if let data = Utils.loadResourceFromBundle(name: fileName, fileEnding: "json", filePath: filePath),
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
                NSLocalizedDescriptionKey: "Server responded with status: \(response.statusCode) (\(errorString)) for url:\(response.url?.absoluteString ?? "")"
            ])
            print("\(error.localizedDescription)")
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

        print("\(responseContent.statusCode) response received from:\(responseContent.urlString)")
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
