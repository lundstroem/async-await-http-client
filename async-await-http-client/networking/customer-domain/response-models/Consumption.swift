//
//  Consumption.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

extension CustomerResponse {

    struct ConsumptionResponse: Codable, Hashable {
        var periodicValues: [Int]
    }
}
