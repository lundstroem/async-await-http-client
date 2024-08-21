//
//  Invoice.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

extension CustomerResponse {

    struct Invoice: Codable, Hashable {
        var invoiceId: Int64
        var invoiceDate: String
        var presentDueDate: String
        var amount: String

        /* Example of handling capitalized keys in response */
        enum CodingKeys: String, CodingKey {
            case invoiceId = "InvoiceId"
            case invoiceDate = "InvoiceDate"
            case presentDueDate = "PresentDueDate"
            case amount = "Amount"
        }
    }

    struct InvoiceListResponseObject: Codable, Hashable {
        var invoiceParts: [Invoice]
    }
}
