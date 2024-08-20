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
        var customerId: Int
        var firstName: String
        var lastName: String
    }
}
