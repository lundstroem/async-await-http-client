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

@Observable @MainActor final class ModelData {

    var customer: CustomerResponse.CustomerResponseObject?
    var consumption: CustomerResponse.ConsumptionResponse?
    var invoiceListResponse: CustomerResponse.InvoiceListResponseObject?

    // Enable creation of instance from non main thread
    nonisolated init() {}

    func fetchData() {

        Task.detached(priority: .background) {
            do {

                let _ = try await HttpService().fetchInvoice(invoiceNumber: "1")
                let _ = try await HttpService().fetchInvoice(invoiceNumber: "2")
                let _ = try await HttpService().fetchInvoice(invoiceNumber: "3")

                /* test various mock status codes */
                let _ = try await HttpService().verifyCustomer(customerId: "1")

                let customerData = try await HttpService().fetchCustomer(personalNumber: "")
                let consumptionData = try await HttpService().fetchCustomerConsumption(id: 1, type: 1)
                let invoiceListResponseData = try await HttpService().fetchInvoices(customerCode: "1")

                await MainActor.run {
                    self.customer = customerData
                    self.consumption = consumptionData
                    self.invoiceListResponse = invoiceListResponseData
                }
            } catch {
                print("error \(error)")
            }
        }
    }
}
