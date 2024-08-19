//
//  APODCacheManager.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation

class APODCacheManager {
	static let shared = APODCacheManager()
	
	private init() {}
	
	func saveAPOD(_ apod: APOD) {
		if let data = try? JSONEncoder().encode(apod) {
			UserDefaults.standard.set(data, forKey: "cachedAPOD")
		}
	}
	
	func loadAPOD() -> APOD? {
		if let data = UserDefaults.standard.data(forKey: "cachedAPOD"),
		   let apod = try? JSONDecoder().decode(APOD.self, from: data) {
			return apod
		}
		return nil
	}
}
