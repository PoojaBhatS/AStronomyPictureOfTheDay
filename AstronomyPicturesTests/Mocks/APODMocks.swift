//
//  APODMocks.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//

import Foundation
@testable import AstronomyPictures

var jsonData: Data? = {
	let jsonPath = Bundle.main.url(forResource: "apod", withExtension: "json")!
	let jsonData = try? Data(contentsOf: jsonPath)
	return jsonData
	
}()

class MockNetworkService: NetworkServiceProviding {
	

	var invokedSessionGetter = false
	var invokedSessionGetterCount = 0
	var stubbedSession: URLSession!
	var session: URLSession {
		invokedSessionGetter = true
		invokedSessionGetterCount += 1
		return stubbedSession
	}

	var invokedGet = false
	var invokedGetCount = 0
	var invokedGetParameters: (url: URL, Void)?

	func get(from url: URL) async throws -> MockNetworkService.Result {
		invokedGet = true
		invokedGetCount += 1
		invokedGetParameters = (url, ())
		
		return .success(jsonData!)
	}
}
