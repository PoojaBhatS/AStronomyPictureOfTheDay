//
//  NetworkService.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

struct NetworkError: Error {}

protocol NetworkServiceProviding {
	var session: URLSession { get }
	typealias Result = Swift.Result<Data, Error>
	func get(from url: URL) async throws -> Result
}
struct HttpStatusCode {
	static let OK_200 = 200
}

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

