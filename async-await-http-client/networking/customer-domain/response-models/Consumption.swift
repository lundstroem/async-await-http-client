//
//  Consumption.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

extension CustomerResponse {

    /*
     {
        "periodicValues": [
            1, 2, 3
        ]
     }
     */

    struct ConsumptionResponse: Codable, Hashable {
        var periodicValues: [Int]
    }
}
