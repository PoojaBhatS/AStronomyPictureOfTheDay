//
//  APODNetworkService.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

protocol APODServiceProtocol {
	func fetchAPOD(for date: String?) async throws -> APOD
}

class APODService: APODServiceProtocol {
	private let baseURL = "https://api.nasa.gov/planetary/apod"
	private let apiKey = "PSsAH6a9iUUDlMwSnaEA4qLRYhoxsA8NwmVdcSey"
	
	func fetchAPOD(for date: String? = nil) async throws -> APOD {
		var urlComponents = URLComponents(string: baseURL)!
		var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
		
		if let date = date {
			queryItems.append(URLQueryItem(name: "date", value: date))
		}
		
		urlComponents.queryItems = queryItems
		
		let (data, _) = try await URLSession.shared.data(from: urlComponents.url!)
		let apod = try JSONDecoder().decode(APOD.self, from: data)
		return apod
	}
}
