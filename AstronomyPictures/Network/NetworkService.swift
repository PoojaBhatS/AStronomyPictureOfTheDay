//
//  NetworkService.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

/// Representation of Error
struct NetworkError: Error {}

struct HttpStatusCode {
	static let OK_200 = 200
}

/// A Protocol that defines the contract for a service that is responsible for fetching data
/// with the help of `URLSession` by making network calls.
protocol NetworkServiceProviding {
	var session: URLSession { get }
	typealias Result = Swift.Result<Data, Error>
	func get(from url: URL) async throws -> Result
}

/// A class that conforms to `NetworkServiceProviding` for fetching data
/// from the network source using an `URLSession` instance
 final class NetworkService: NetworkServiceProviding {
	let session: URLSession
	init(session: URLSession) {
		self.session = session
	}
	
	func get(from url: URL) async throws -> NetworkServiceProviding.Result {
		
		do {
			let (data, response) = try await session.data(from: url)
			if (response as? HTTPURLResponse)?.statusCode == HttpStatusCode.OK_200  {
				return .success(data)
			} else {
				throw NetworkError()
			}
		}
		catch {
			throw NetworkError()
		}
	}
}

