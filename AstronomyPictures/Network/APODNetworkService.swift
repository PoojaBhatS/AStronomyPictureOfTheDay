//
//  APODNetworkService.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

protocol APODNetworkServiceProviding {
	var networkService: NetworkServiceProviding { get }
	func loadData(for date: Date?) async throws -> APODData
	func loadData(from url: URL) async throws -> Data
}

final class APODNetworkService: APODNetworkServiceProviding {
	
	enum Error: Swift.Error {
		case connectivity, invalidData
	}
	
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
						throw Error.invalidData
					}
					
				case .failure:
					throw Error.connectivity
			}

		}
		catch {
			throw Error.connectivity
		}
	}

	
	func loadData(from url: URL) async throws -> Data {
		do {
			let result = try await networkService.get(from: url)
			switch result {
				case let .success(data):
						return data
				case .failure:
					throw Error.connectivity
			}
		}
		catch {
			throw Error.connectivity
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
			throw APODNetworkService.Error.invalidData
		}
		return decodable
	}
}

private extension Date {
	var asFormattedString: String {
		Utilities.dateFormatter.string(from: self)
	}
}
