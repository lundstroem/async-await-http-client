//
//  CustomerRequestModel.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

class CustomerRequestModel: BaseRequestModel {

    private let personalNumber: String

    init(personalNumber: String) {
        self.personalNumber = personalNumber
    }
}
