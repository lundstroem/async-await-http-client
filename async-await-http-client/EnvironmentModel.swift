/*

 MIT License

 Copyright (c) 2024 Harry Lundström

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */
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
