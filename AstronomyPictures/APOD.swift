//
//  APODModel.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

struct APOD: Codable {
	let date: String
	let explanation: String
	let title: String
	let url: String
	let mediaType: String
	
	enum CodingKeys: String, CodingKey {
		case date, explanation, title, url
		case mediaType = "media_type"
	}
}
