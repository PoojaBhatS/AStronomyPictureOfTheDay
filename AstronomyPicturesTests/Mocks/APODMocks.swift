//
//  APODMocks.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//

import Foundation
@testable import AstronomyPictures

let jsonData: Data? = {
	let jsonPath = Bundle.main.url(forResource: "apod", withExtension: "json")!
	let jsonData = try? Data(contentsOf: jsonPath)
	return jsonData
	
}()

let mockURLSession: URLSession = {
	let config: URLSessionConfiguration = .ephemeral
	URLProtocol.registerClass(MockingURLProtocol.self)
	config.protocolClasses = [MockingURLProtocol.self]
	return URLSession(configuration: config)
}()

extension APOD {
	static var mock: APOD {
		return APOD(
			date: Utilities.dateFormatter.date(from: "2023-08-20") ?? Date(),
			explanation: "This is a mock explanation.",
			title: "Mock Title",
			url: "https://example.com/mock.jpg",
			mediaType: .image
		)
	}
}

/// Mock for NetworkServiceProviding
final class MockNetworkService: NetworkServiceProviding {
	var session: URLSession
	var result: Result<Data, Error>?
	var invokedGetFromUrl = false
	
	
	init(session: URLSession, result: Result<Data, Error>? = nil) {
		self.session = session
		self.result = result
	}
	
	func get(from url: URL) async throws -> NetworkServiceProviding.Result {
		invokedGetFromUrl = true
		if let result = result {
			return result
		} else {
			throw NetworkError() // Default error if no result is set
		}
	}
}

/// Mock for AppConfigurationProviding
final class MockAppConfiguration: AppConfigurationProviding {
	var apiBaseURL: String = "https://mockapi.nasa.gov"
	var apiKey: String = "mock-api-key"
}

/// Mock for APODNetworkServiceProviding
final class MockAPODNetworkService: APODNetworkServiceProviding {
	
	var networkService: NetworkServiceProviding
	var loadDataForDateResult: Result<APODData, Error>?
	var loadDataFromURLResult: Result<Data, Error>?
	
	init(networkService: NetworkServiceProviding) {
		self.networkService = networkService
	}
	
	func loadData(for date: Date?) async throws -> APODData {
		switch loadDataForDateResult {
			case .success(let data):
				return data
			case .failure(let error):
				throw error
			case .none:
				fatalError("loadDataForDateResult is not set")
		}
	}
	
	func loadData(from url: URL) async throws -> Data {
		switch loadDataFromURLResult {
			case .success(let data):
				return data
			case .failure(let error):
				throw error
			case .none:
				fatalError("loadDataFromURLResult is not set")
		}
	}
}

/// Mock for APODDataManagerProviding
final class MockAPODDataManager: APODDataManagerProviding {
	var storeAPODDataCalled = false
	var storeAPODImageDataCalled = false
	var fetchAPODResult: (APODData?, Error?)?
	
	func storeAPOD(data: APODData) {
		storeAPODDataCalled = true
	}
	
	func storeAPODImage(imageData: Data, date: Date) {
		storeAPODImageDataCalled = true
	}
	
	func fetchAPODFor(date: Date, completionHandler: @escaping (APODData?, Error?) -> Void) {
		completionHandler(fetchAPODResult?.0, fetchAPODResult?.1)
	}
}
