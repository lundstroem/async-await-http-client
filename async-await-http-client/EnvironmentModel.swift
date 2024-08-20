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
            } catch {
                print("error \(error)")
            }
        }
    }
}
