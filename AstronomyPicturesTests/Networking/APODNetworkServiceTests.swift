//
//  APODNetworkServiceTests.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//


import XCTest
@testable import AstronomyPictures

final class APODNetworkServiceTests: XCTestCase {
	var mockNetworkService: MockNetworkService!
	var mockAppConfiguration: MockAppConfiguration!
	var serviceUnderTest: APODNetworkService!
	
	override func setUp() {
		super.setUp()
		mockNetworkService = MockNetworkService(session: mockURLSession)
		mockAppConfiguration = MockAppConfiguration()
		serviceUnderTest = APODNetworkService(appConfiguration: mockAppConfiguration, networkService: mockNetworkService)
	}
	
	override func tearDown() {
		mockNetworkService = nil
		mockAppConfiguration = nil
		serviceUnderTest = nil
		super.tearDown()
	}
	
	func testLoadDataForDateReturnsAPODData() async throws {
		// Given
		let expectedData = try APODResponseMapper<APOD>.encodeAndMap(APOD.mock)
		mockNetworkService.result = .success(expectedData)
		
		// When
		let apodData = try await serviceUnderTest.loadData(for: nil)
		
		// Then
		XCTAssertEqual(apodData.title, APOD.mock.title, "Expected title does not match the result.")
		XCTAssertEqual(apodData.explanation, APOD.mock.explanation, "Expected explanation does not match the result.")
	}
	
	
	func testLoadDataForDateThrowsInvalidDataError() async throws {
		// Given
		let invalidData = Data() // Empty data
		mockNetworkService.result = .success(invalidData)
		
		// When and Then
		do {
			let _ = try await serviceUnderTest.loadData(for: nil)
			XCTFail("Expected to throw invalidData error, but succeeded.")
		} catch {
			XCTAssertTrue(error is DataServiceError, "Expected DataServiceError.invalidData, but got a different error.")
		}
	}
	
	
	func testLoadDataFromURLReturnsData() async throws {
		// Arrange
		let expectedData = "Test data".data(using: .utf8)!
		mockNetworkService.result = .success(expectedData)
		let url = URL(string: "https://example.com")!
		
		// Act
		let data = try await serviceUnderTest.loadData(from: url)
		
		// Assert
		XCTAssertEqual(data, expectedData, "Expected data does not match the result.")
	}
	
	func testLoadDataFromURLThrowsError() async throws {
		// Arrange
		mockNetworkService.result = .failure(NetworkError())
		let url = URL(string: "https://example.com")!
		
		// Act & Assert
		do {
			let _ = try await serviceUnderTest.loadData(from: url)
			XCTFail("Expected to throw connectivity error, but succeeded.")
		} catch {
			XCTAssertTrue(error is DataServiceError, "Expected DataServiceError.invalidData, but got a different error.")
		}
	}
	
	
}
