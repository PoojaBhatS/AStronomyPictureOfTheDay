//
//  APODViewModelTests.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//

import XCTest
import Combine

@testable import AstronomyPictures

final class APODViewModelTests: XCTestCase {
	
	var sut: APODViewModel!
	var mockNetworkService: MockAPODNetworkService!
	var mockDataStorage: MockAPODDataManager!
	var cancellables = Set<AnyCancellable>()
	
	
	@MainActor override func setUp() {
		super.setUp()
		let mockNetworkServiceProvider = MockNetworkService(session: mockURLSession)
		mockNetworkService = MockAPODNetworkService(networkService: mockNetworkServiceProvider)
		mockDataStorage = MockAPODDataManager()
		
		sut = APODViewModel(dependencies: .init(
			networkService: mockNetworkService,
			dataStorage: mockDataStorage
		))
	}
	
	override func tearDown() {
		sut = nil
		mockNetworkService = nil
		mockDataStorage = nil
		super.tearDown()
	}
	
	func testFetchAPODSuccessfulLoad() async {
		// Given
		let expectedAPODData = APODData(
			date: Date(),
			explanation: "Test explanation",
			title: "Test title",
			url: "https://example.com",
			mediaType: .image
		)
		mockNetworkService.loadDataForDateResult = .success(expectedAPODData)
		
		let expectation = XCTestExpectation(description: "Publishes apod display state")
		
		await sut.$apodDisplayState
		// Remove the first 2 values - we don't need it
			.dropFirst(2)
			.sink(receiveValue: {
				XCTAssertEqual($0.item, .init(item: expectedAPODData, isLoading: false))
				// Fulfill the expectation
				expectation.fulfill()
			})
			.store(in: &cancellables)
		
		//When
		await sut.loadInitially()
		
		//Then
		await fulfillment(of: [expectation], timeout: 1)
		XCTAssertTrue(self.mockDataStorage.storeAPODDataCalled, "APOD data should be stored in the data manager.")
		
	}
	
	func testFetchImageDataSuccessfulLoad() async {
		// Given
		let imageData = "Test Image Data".data(using: .utf8)!
		let date = Date()
		let expectedAPODData = APODData(
			date: date,
			explanation: "Test explanation",
			title: "Test title",
			url: "https://example.com",
			mediaType: .image,
			imageData: imageData
		)
		
		mockNetworkService.loadDataFromURLResult = .success(imageData)
		mockDataStorage.fetchAPODResult = (expectedAPODData, nil)
		
		let expectation = XCTestExpectation(description: "Publishes apod display state")
		
		await sut.$apodDisplayState
		// Remove the first 2 values - we don't need it
			.dropFirst()
			.sink(receiveValue: {
				XCTAssertEqual($0.item, .init(item: expectedAPODData, isLoading: false))
				
				// Fulfill the expectation
				expectation.fulfill()
			})
			.store(in: &cancellables)
		
		//When
		await sut.loadImage(from: "https://example.com", date: date)
		
		//Then
		await fulfillment(of: [expectation], timeout: 1)
		XCTAssertTrue(self.mockDataStorage.storeAPODImageDataCalled, "APOD Image data should be stored in the data manager.")
	}
}
