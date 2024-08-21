//
//  Network+Helpers.swift
//  AstronomyPictures
//
//  Created by Pooja on 21/08/2024.
//

enum DataServiceError: Error {
	case connectivity, invalidData, invalidURL
}


extension Error {
	var title: String {
		return switch self as? DataServiceError {
			case .connectivity:
				"You are offline"
			case .invalidData, .invalidURL:
				"Content Unavailable"
			default:
				"Unknown error"
		}
	}
	
	var message: String {
		return switch self as? DataServiceError {
			case .connectivity:
				"Some features are not available when you are offline. Please connect to the internet and try again later."
			case .invalidData, .invalidURL:
				"This content is currently not available."
			default:
				"Connection error. Please try again later."
		}
	}
}

