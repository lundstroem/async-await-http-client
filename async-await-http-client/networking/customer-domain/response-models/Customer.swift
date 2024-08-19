//
//  Customer.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

class CustomerResponse {

    /*
     {
        "customer": {
            "customerId": 1,
            "firstName": "Test",
            "lastName": "Testsson"
        }
     }
     */

    struct CustomerResponseObject: Codable, Hashable {
        var customer: Customer
    }

    struct Customer: Codable, Hashable {
        var customerId: Int64
        var firstName: String
        var lastName: String
    }
}
