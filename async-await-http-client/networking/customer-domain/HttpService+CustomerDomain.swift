//
//  HttpService+DefaultDomain.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

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
                                  type: Int32) async throws -> CustomerResponse.ConsumptionResponse? {

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

    func verifyCustomer(customerId: String) async throws -> ResponseContent? {
        let url = baseUrl+"api/v1/customers/customer/verify/\(customerId)"
        let responseContent: ResponseContent = try await makeRequest(urlString: url,
                                                                     httpMethod: .post,
                                                                     contentType: .unspecified)
        if responseContent.statusCode == 200 {
            return responseContent
        }
        return nil
    }
}
