//
//  Invoice.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

extension CustomerResponse {

    /*
     {
        "invoiceParts": [
            {
                "invoiceId": 1,
                "invoiceDate": "2024-04-01",
                "presentDueDate": "2024-04-28",
                "amount": "1042.0"
            },
            {
                "invoiceId": 2,
                "invoiceDate": "2024-05-01",
                "presentDueDate": "2024-05-28",
                "amount": "2146.0"
            },
            {
                "invoiceId": 3,
                "invoiceDate": "2024-06-01",
                "presentDueDate": "2024-06-28",
                "amount": "2146.0"
            }
        ]
     }
     */

    struct Invoice: Codable, Hashable {
        var invoiceId: Int64
        var invoiceDate: String
        var presentDueDate: String
        var amount: String
    }

    struct InvoiceListResponseObject: Codable, Hashable {
        var invoiceParts: [Invoice]
    }
}
