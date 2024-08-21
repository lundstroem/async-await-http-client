//
//  async_await_http_clientTests.swift
//  async-await-http-clientTests
//
//  Created by user on 2024-08-19.
//

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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testFetchMockCustomer() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchCustomer(personalNumber: "")
        XCTAssertNotNil(response)
    }

    func testFetchMockConsumption() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchCustomerConsumption(id: 1, type: 1)
        XCTAssertNotNil(response?.periodicValues)
    }

    func testFetchMockInvoices() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchInvoices(customerCode: "1")
        XCTAssertNotNil(response?.invoiceParts)
    }

    func testFetchMockInvoice1() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchInvoice(invoiceNumber: "1")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockInvoice2() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchInvoice(invoiceNumber: "2")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockInvoice3() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.fetchInvoice(invoiceNumber: "3")
        XCTAssertNotNil(response?.data)
    }

    func testFetchMockVerification() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 200)
        XCTAssertTrue(response?.statusCode == 200)
    }

    func testMockVerificationWithStatus400() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 400)
        XCTAssertTrue(response?.statusCode == 400)
    }

    func testMockVerificationWithStatus500() async throws {
        let httpService = await HttpService(useMock: true)
        let response = try await httpService.verifyCustomer(customerId: "1", mockStatusCode: 500)
        XCTAssertTrue(response?.statusCode == 500)
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
