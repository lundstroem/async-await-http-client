//
//  Invoice.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

extension CustomerResponse {

    struct Invoice: Codable, Hashable {
        let invoiceId: Int64
        let invoiceDate: String
        let presentDueDate: String
        let amount: String

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
