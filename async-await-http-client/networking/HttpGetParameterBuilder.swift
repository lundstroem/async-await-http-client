//
//  HttpGetParameterBuilder.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

class HttpGetParameterBuilder {

    private var parameterCount = 0
    private var params: String = ""

    private func appendDelimiter() {
        params.append(parameterCount == 0 ? "?" : "&")
        parameterCount += 1
    }

    private func urlEncode(_ value: String) -> String {
        let urlEncoded = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        return urlEncoded ?? ""
    }

    func append(name: String, double: Double?) {
        guard let double = double else { return }
        appendDelimiter()
        params.append("\(name)=\(double)")
    }

    func append(name: String, int32: Int32?) {
        guard let int32 = int32 else { return }
        appendDelimiter()
        params.append("\(name)=\(int32)")
    }

    func append(name: String, int64: Int64?) {
        guard let int64 = int64 else { return }
        appendDelimiter()
        params.append("\(name)=\(int64)")
    }

    func append(name: String, string: String?) {
        guard let string = string else { return }
        appendDelimiter()
        params.append("\(name)=\(urlEncode(string))")
    }

    func append(name: String, bool: Bool?) {
        guard let bool = bool else { return }
        appendDelimiter()
        params.append("\(name)=\(bool)")
    }

    var parameterString: String {
        params
    }
}
