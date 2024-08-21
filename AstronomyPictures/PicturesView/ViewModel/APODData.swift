//
//  APODData.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

struct APODData: Equatable {
	var date: Date
	var explanation: String
	var title: String
	var url: String
	var mediaType: MediaType
	var imageData: Data?
}
