//
//  BaseRequestModel.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

class BaseRequestModel: Encodable {

    // TODO: If capitalized parameter names are needed, find a way to avoid having
    // capitalized variable names which are not inline with Swift coding standards.
    // Maybe enum CodingKeys?

    func makeHttpBodyData() -> Data? {
        let parsedBody = try? JSONEncoder().encode(self)
        return parsedBody
    }

    private func urlEncode(_ value: String) -> String {
        let urlEncoded = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        return urlEncoded ?? ""
    }
}
