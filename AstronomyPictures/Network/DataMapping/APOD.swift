//
//  APODModel.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

struct APODResponse: Codable {
	let items: [APOD]
}

struct APOD: Codable {
	let date: Date
	let explanation: String
	let title: String
	let url: String
	let mediaType: MediaType
	
	enum CodingKeys: String, CodingKey {
		case date, explanation, title, url
		case mediaType = "media_type"
	}
}

enum MediaType: String, Codable {
	case image
	case video
	case unknown = ""
	
	var value: String {
		rawValue
	}
}
