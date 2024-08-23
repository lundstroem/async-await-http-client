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

import XCTest
@testable import async_await_http_client

final class async_await_http_clientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        // self.measure {
            // Put the code you want to measure the time of here.
        // }
    }

    func testFetchMockCustomer() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchCustomer(personalNumber: "")
        XCTAssertNotNil(response)
    }

    func testFetchMockConsumption() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchCustomerConsumption(id: 1, type: 1)
        XCTAssertNotNil(response?.periodicValues)
    }

    func testFetchMockInvoices() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchInvoices(customerCode: "1")
        XCTAssertNotNil(response?.invoiceParts)
    }

    func testFetchMockInvoice1() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchInvoice(invoiceNumber: "1")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockInvoice2() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchInvoice(invoiceNumber: "2")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockInvoice3() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.fetchInvoice(invoiceNumber: "3")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockVerification() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 200)
        XCTAssertTrue(response?.response?.statusCode == 200)
    }

    func testMockVerificationWithStatus400() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 400)
        XCTAssertTrue(response?.response?.statusCode == 400)
    }

    func testMockVerificationWithStatus500() async throws {
        let httpService = HttpServiceMock()
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 500)
        XCTAssertTrue(response?.response?.statusCode == 500)
    }

    func testCustomerRequestModelEncoding() {
        let requestModel = CustomerRequestModel(personalNumber: "1")
        let data = requestModel.makeHttpBodyData()

        guard let data = data else {
            XCTFail()
            return
        }

        let jsonString = String(data: data, encoding: .utf8)
        guard let jsonString = jsonString else {
            XCTFail()
            return
        }

        XCTAssertTrue(jsonString.contains("\"PersonalNumber\""))
    }
}
