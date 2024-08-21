//
//  APODNetworkService.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

/// A Protocol that defines the contract for a service that is responsible for fetching data
/// related to Astronomy Picture Of the Day(APOD) from a network source
protocol APODNetworkServiceProviding {
	var networkService: NetworkServiceProviding { get }
	func loadData(for date: Date?) async throws -> APODData
	func loadData(from url: URL) async throws -> Data
}

/// A class that conforms to `APODNetworkServiceProviding` for fetching data
/// related to Astronomy Picture Of the Day(APOD) from a network source
final class APODNetworkService: APODNetworkServiceProviding {
		
	let networkService: NetworkServiceProviding
	let appConfiguration: AppConfigurationProviding
	
	init(
		appConfiguration: AppConfigurationProviding,
		networkService: NetworkServiceProviding
	) {
		self.networkService = networkService
		self.appConfiguration = appConfiguration
	}
	
	func loadData(for date: Date?) async throws -> APODData {
		var urlComponents = URLComponents(string: appConfiguration.apiBaseURL)
		let queryItems = [
			"api_key": appConfiguration.apiKey,
			"date" : date?.asFormattedString
		].compactMapValues { $0 }
		urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
		
		guard let url = urlComponents?.url
		else {
			throw DataServiceError.invalidURL
		}
		do {
			
			let result = try await networkService.get(from: url)
			switch result {
				case let .success(data):
					do {
						let apodResponse = try APODResponseMapper<APOD>.decodeAndMap(data)
						return APODData(from: apodResponse)
					} catch {
						throw DataServiceError.invalidData
					}
					
				case .failure:
					throw DataServiceError.invalidData
			}

		}
		catch {
			throw DataServiceError.invalidData
		}
	}

	
	func loadData(from url: URL) async throws -> Data {
		do {
			let result = try await networkService.get(from: url)
			switch result {
				case let .success(data):
						return data
				case .failure:
					throw DataServiceError.invalidData
			}
		}
		catch {
			throw DataServiceError.invalidData
		}
	}
}


private extension Array where Element == APOD {
	func toModels() -> [APODData] {
		return map {
			.init(
				date: $0.date,
				explanation: $0.explanation,
				title: $0.title,
				url: $0.url,
				mediaType: $0.mediaType
			)
		}
	}
}

private extension APODData {
	init(from apod: APOD) {
		self.date = apod.date
		self.explanation = apod.explanation
		self.title = apod.title
		self.url = apod.url
		self.mediaType = apod.mediaType
	}
}


final class APODResponseMapper<T: Decodable> {
	
	static func decodeAndMap(_ data: Data) throws -> T {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(Utilities.dateFormatter)
		guard let decodable = try? decoder.decode(T.self, from: data) else {
			throw DataServiceError.invalidData
		}
		return decodable
	}
	
	static func encodeAndMap(_ T: Codable) throws -> Data {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(Utilities.dateFormatter)
		guard let encodedData = try? encoder.encode(T.self) else {
			throw DataServiceError.invalidData
		}
		return encodedData
	}

}

private extension Date {
	var asFormattedString: String {
		Utilities.dateFormatter.string(from: self)
	}
}
