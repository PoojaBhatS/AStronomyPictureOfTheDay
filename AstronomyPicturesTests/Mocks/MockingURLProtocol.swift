//
//  MockingURLProtocol.swift
//  AstronomyPicturesTests
//
//  Created by Pooja on 21/08/2024.
//

import Foundation
///Mock for URLProtocol to help testing `NSURLSesson`
final class MockingURLProtocol: URLProtocol {
	static var data: Data?
	static var response: URLResponse?
	static var error: Error?
	
	override class func canInit(with request: URLRequest) -> Bool {
		true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}
	
	override func startLoading() {
		if let data = Self.data {
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocol(self, didReceive: MockingURLProtocol.response ?? .init(), cacheStoragePolicy: .notAllowed)
			client?.urlProtocolDidFinishLoading(self)
		} else if let error = Self.error {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}
	
	override func stopLoading() {}
}

