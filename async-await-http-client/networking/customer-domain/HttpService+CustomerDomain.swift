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

extension HttpService {

    func fetchCustomer(personalNumber: String) async throws -> CustomerResponse.CustomerResponseObject? {
        let url = baseUrl+"api/v1/customers/customer"
        let requestModel = CustomerRequestModel(personalNumber: personalNumber)
        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     httpMethod: .post,
                                                                     httpBody: requestModel.makeHttpBodyData(),
                                                                     contentType: .json)
        if responseContent.statusCode == 200 {
            let object = try await decodeResponseData(decodable: CustomerResponse.CustomerResponseObject.self, responseContent: responseContent)
            return object
        }
        return nil
    }

    func fetchCustomerConsumption(id: Int64,
                                  type: Int32,
                                  mockStatusCode: Int? = nil) async throws -> CustomerResponse.ConsumptionResponse? {

        let getRequestBuilder = HttpGetParameterBuilder()

        getRequestBuilder.append(name: "id", int64: id)
        getRequestBuilder.append(name: "type", int32: type)

        let url = baseUrl+"api/v1/customers/customer/consumption"+getRequestBuilder.parameterString

        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     contentType: .json)

        if responseContent.statusCode == 200 {
            let object  = try await decodeResponseData(decodable: CustomerResponse.ConsumptionResponse.self, responseContent: responseContent)
            return object
        }
        return nil
    }

    func fetchInvoices(customerCode: String) async throws -> CustomerResponse.InvoiceListResponseObject? {
        let url = baseUrl+"api/v1/customers/\(customerCode)/invoices"
        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     contentType: .json)
        if responseContent.statusCode == 200 {
            var object = try await decodeResponseData(decodable: CustomerResponse.InvoiceListResponseObject.self,
                                                      responseContent: responseContent)

            // Sort invoices

            var invoiceArray = object.invoiceParts.compactMap { $0 }
            invoiceArray.sort { $0.presentDueDate > $1.presentDueDate }
            object.invoiceParts = invoiceArray

            return object
        }
        return nil
    }

    func fetchInvoice(invoiceNumber: String) async throws -> ResponseContent? {
        let url = baseUrl+"api/v1/customers/customer/\(invoiceNumber)/invoice"
        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     contentType: .pdf)
        if responseContent.statusCode == 200 {
            return responseContent
        }
        return nil
    }

    func verifyCustomer(customerId: String, mockStatusCode: Int? = nil) async throws -> ResponseContent? {

        /* Example request which does not return JSON or data, only a status code */

        let url = baseUrl+"api/v1/customers/customer/verify/\(customerId)"
        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     httpMethod: .post,
                                                                     mockResponseStatusCode: mockStatusCode,
                                                                     contentType: .unspecified)
        return responseContent
    }
}
