//
//  APODViewModel.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation
import SwiftUI

@MainActor
class APODViewModel: ObservableObject {
	@Published var apod: APOD?
	@Published var errorMessage: String?
	private let apodService: APODServiceProtocol
	
	init(apodService: APODServiceProtocol = APODService()) {
		self.apodService = apodService
	}
	
	func fetchAPOD(for date: String? = nil) async {
		do {
			let apod = try await apodService.fetchAPOD(for: date)
			self.apod = apod
			// Save the latest APOD in the cache.
			APODCacheManager.shared.saveAPOD(apod)
		} catch {
			// Load cached APOD if fetching fails.
			if let cachedAPOD = APODCacheManager.shared.loadAPOD() {
				self.apod = cachedAPOD
			} else {
				self.errorMessage = "Failed to load APOD."
			}
		}
	}
	
	func formatDate(_ date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd MMM y"
		return dateFormatter.string(from: date)
	}

}
