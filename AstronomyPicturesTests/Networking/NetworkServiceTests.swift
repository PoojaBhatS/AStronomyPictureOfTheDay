//
//  NetworkServiceTests.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//

import XCTest
@testable import AstronomyPictures

final class NetworkServiceTests: XCTestCase {
	var mockSession: URLSession!
	var serviceUnderTest: NetworkService!
	
	override func setUp() {
		super.setUp()
		mockSession = mockURLSession
		serviceUnderTest = NetworkService(session: mockSession)
	}
	
	override func tearDown() {
		mockSession = nil
		serviceUnderTest = nil
		super.tearDown()
	}
	
	func testGetResponseReturnsData() async throws {
		// Given
		let expectedData = jsonData
		let url = URL(string: "https://example.com")!
		MockingURLProtocol.data = jsonData
		MockingURLProtocol.response = URLResponse.successResponse
		
		
		// When
		let result = try await serviceUnderTest.get(from: url)
		
		// Then
		switch result {
			case .success(let data):
				XCTAssertEqual(data, expectedData, "Expected data does not match the result.")
			case .failure:
				XCTFail("Expected successful response, but received failure.")
		}
	}
	
	func testGetResponseThrowsNetworkError() async throws {
		// Given
		let url = URL(string: "https://example.com")!
		MockingURLProtocol.data = nil
		MockingURLProtocol.response = URLResponse.errorResponse
		
		// When
		do {
			let _ = try await serviceUnderTest.get(from: url)
			XCTFail("Expected NetworkError to be thrown, but it was not.")
		} catch {
			// Then
			XCTAssertTrue(error is NetworkError, "Expected NetworkError, but received a different error.")
		}
	}
	
	func testThrowsNetworkError() async throws {
		// Given
		let url = URL(string: "https://example.com")!
		MockingURLProtocol.error = NetworkError()
		MockingURLProtocol.data = nil
		MockingURLProtocol.response = nil
		
		// When
		do {
			let _ = try await serviceUnderTest.get(from: url)
			XCTFail("Expected NetworkError to be thrown, but it was not.")
		} catch {
			// Then
			XCTAssertTrue(error is NetworkError, "Expected NetworkError, but received a different error.")
		}
	}
	
}

private extension URLResponse {
	static var successResponse: HTTPURLResponse? {
		return HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: HttpStatusCode.OK_200, httpVersion: nil, headerFields: nil)
	}
	
	static var errorResponse: HTTPURLResponse? {
		return HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
	}
	
}

