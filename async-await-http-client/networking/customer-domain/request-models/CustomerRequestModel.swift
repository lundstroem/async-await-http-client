//
//  CustomerRequestModel.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

struct CustomerRequestModel: Encodable {

    let personalNumber: String

    enum CodingKeys: String, CodingKey {
        case personalNumber = "PersonalNumber"
    }

    func makeHttpBodyData() -> Data? {
        let parsedBody = try? JSONEncoder().encode(self)
        return parsedBody
    }
}
