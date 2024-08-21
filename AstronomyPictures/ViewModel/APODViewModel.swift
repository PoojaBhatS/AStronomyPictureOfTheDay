//
//  APODViewModel.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import Foundation
import SwiftUI

typealias APODDisplay = GenericDisplay<APODDisplayState>

extension APODDisplay {
	static var initial: Self {
		.display(
			item: APODDisplayState(
				item: nil,
				isLoading: true
			)
		)
	}
}

/// A struct that defines the display state for the `APODView`
struct APODDisplayState: Equatable {
	let item: APODData?
	var isLoading: Bool
}

/// A Protocol that defines the contract for a class that is responsible for receiving
/// inputs from the view and sending updates when the view needs to be updated
protocol APODViewModelInput {
	func loadInitially()
	func loadData(for date: Date)
	func loadImage(from url: String, date: Date)
}


@MainActor
final class APODViewModel: ObservableObject {

	struct Dependencies {
		let networkService: APODNetworkServiceProviding
		let dataStorage: APODDataManagerProviding
	}
	
	private let dependencies: Dependencies

	@Published var apodDisplayState: APODDisplay = .initial

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	 /// Function to fetch the APOD data from network/persistence storage if the network call fails asynchronously
	 /// - Parameter date: `Date` to fetch the data for
	private func fetchAPOD(for date: Date? = nil) async {
		do {
			let apod = try await dependencies.networkService.loadData(for: date)
			self.apodDisplayState = .display(item: .init(item: apod, isLoading: false))
			// Save the latest APOD in the cache.
			dependencies.dataStorage.storeAPOD(data: apod)
		} catch let error {
			// Load cached APOD if fetching fails.
			guard let date else {
				self.apodDisplayState = .error(error: DataServiceError.invalidData)
				return
			}
			dependencies.dataStorage.fetchAPODFor(date: date) { apod, _ in
				if let cachedAPOD = apod {
					self.apodDisplayState = .display(item: .init(item: cachedAPOD, isLoading: false))
				} else {
					self.apodDisplayState = .error(error: error as? DataServiceError ?? .invalidData)
				}
			}
		}
	}
	
	///Function to fetch the image from url
	 ///- parameter url: URL of the image to be loaded
	 ///- parameter date: date of the APOD object that is already stored
	private func fetchImageData(from url: URL, date: Date) async {
		do {
			let imageData = try await dependencies.networkService.loadData(from: url)
			dependencies.dataStorage.storeAPODImage(imageData: imageData, date: date)
			dependencies.dataStorage.fetchAPODFor(date: date) { apodData, error in
				if let apodData {
					self.apodDisplayState = .display(item: APODDisplayState(item: apodData, isLoading: false))
				} else {
					self.apodDisplayState = .error(error: .invalidData)
				}
			}
		} catch {
			apodDisplayState = .error(error: .invalidData)
		}
	}
}

extension APODViewModel: APODViewModelInput {
	func loadImage(from url: String, date: Date) {
		guard let url = URL(string: url) else {
			return
		}
		Task { @MainActor in
			await fetchImageData(from: url, date: date)
		}

	}
	
	func loadInitially() {
		apodDisplayState = .initial
		Task { @MainActor in
			await fetchAPOD()
		}
	}
	
	func loadData(for date: Date) {
		apodDisplayState = .initial
		Task { @MainActor in
			await fetchAPOD(for: date)
		}
	}
}
