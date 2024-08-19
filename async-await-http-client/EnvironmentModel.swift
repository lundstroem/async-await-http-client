//
//  EnvironmentModel.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import Foundation

@MainActor
final class EnvironmentModel: ObservableObject {

    @Published var invoiceListResponse: CustomerResponse.InvoiceListResponseObject?

    func fetchCustomer() {
        Task {
            do {
                let customer = try await HttpService.shared.fetchCustomer(personalNumber: "")
            } catch {
                print("error \(error)")
            }
        }
    }

    func fetchInvoiceList() {
        Task {
            do {
                // TODO: Remove hardcoded customerCode.
                invoiceListResponse = try await HttpService.shared.fetchInvoices(customerCode: "436075")
            } catch {
                print("error \(error)")
            }
        }
    }
}
