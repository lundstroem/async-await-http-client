//
//  EnvironmentModel.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

@MainActor
final class EnvironmentModel: ObservableObject {

    @Published var customer: CustomerResponse.CustomerResponseObject?
    @Published var consumption: CustomerResponse.ConsumptionResponse?
    @Published var invoiceListResponse: CustomerResponse.InvoiceListResponseObject?

    func fetchData() {
        Task {
            do {
                customer = try await HttpService.shared.fetchCustomer(personalNumber: "")
                consumption = try await HttpService.shared.fetchCustomerConsumption(id: 1, type: 1)
                invoiceListResponse = try await HttpService.shared.fetchInvoices(customerCode: "1")

                let _ = try await HttpService.shared.fetchInvoice(invoiceNumber: "1")
                let _ = try await HttpService.shared.fetchInvoice(invoiceNumber: "2")
                let _ = try await HttpService.shared.fetchInvoice(invoiceNumber: "3")

                /* test various mock status codes */
                let _ = try await HttpService.shared.verifyCustomer(customerId: "1", mockStatusCode: 200)
                let _ = try await HttpService.shared.verifyCustomer(customerId: "1", mockStatusCode: 400)
                let _ = try await HttpService.shared.verifyCustomer(customerId: "1", mockStatusCode: 500)

            } catch {
                print("error \(error)")
            }
        }
    }
}
