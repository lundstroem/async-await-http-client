//
//  Customer.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

class CustomerResponse {

    struct CustomerResponseObject: Codable, Hashable {
        let customerId: Int
        let firstName: String
        let lastName: String
    }
}
