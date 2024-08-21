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

struct APODDisplayState: Equatable {
	let item: APODData?
	var isLoading: Bool
}

protocol APODViewModelInput {
	func loadInitially()
	func loadData(for date: Date)
	func loadImage(from url: String, date: Date)
}


@MainActor
final class APODViewModel: ObservableObject {

	struct Dependencies {
		let networkService: APODNetworkServiceProviding
		let dataStorage: APODDataManager
	}
	
	private let dependencies: Dependencies

	@Published var apod: APODDisplay = .initial

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func fetchAPOD(for date: Date? = nil) async {
		do {
			let apod = try await dependencies.networkService.loadData(for: date)
			self.apod = .display(item: .init(item: apod, isLoading: false))
			// Save the latest APOD in the cache.
			dependencies.dataStorage.storeAPOD(data: apod)
		} catch let error {
			// Load cached APOD if fetching fails.
			guard let date else {
				self.apod = .error(error: DataServiceError.unknown)
				return
			}
			dependencies.dataStorage.fetchAPODFor(date: date) { apod, _ in
				if let cachedAPOD = apod {
					self.apod = .display(item: .init(item: cachedAPOD, isLoading: false))
				} else {
					self.apod = .error(error: error as? DataServiceError ?? .unknown)
				}
			}
		}
	}
	
	func fetchImageData(from url: URL, date: Date) async {
		do {
			let imageData = try await dependencies.networkService.loadData(from: url)
			dependencies.dataStorage.storeAPODImage(imageData: imageData, date: date)
			dependencies.dataStorage.fetchAPODFor(date: date) { apodData, error in
				if let apodData {
					self.apod = .display(item: APODDisplayState(item: apodData, isLoading: false))
				} else {
					self.apod = .error(error: .unknown)
				}
			}
		} catch {
			apod = .error(error: .unknown)
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
		apod = .initial
		Task { @MainActor in
			await fetchAPOD()
		}
	}
	
	func loadData(for date: Date) {
		apod = .initial
		Task { @MainActor in
			await fetchAPOD(for: date)
		}
	}
}

enum DataServiceError: Error {
	case notReachable
	case invalidJSON
	case invalidURL
	case cancelled
	case unknown
}

extension Error {
	var title: String {
		return switch self as? DataServiceError {
			case .notReachable:
				"You are offline"
			case .invalidJSON,
					.invalidURL,
					.unknown:
				"Content Unavailable"
			default:
				"Unknown error"
		}
	}

	var message: String {
		return switch self as? DataServiceError {
			case .notReachable:
				"Some features are not available when you are offline. Please connect to the internet and try again later."
			case .invalidJSON,
					.invalidURL,
					.unknown:
				"This content is currently not available."
			default:
				"Connection error. Please try again later."
		}
	}
}

protocol StateContainer {
	associatedtype Item
}

protocol GenericDisplayProtocol {
	associatedtype Item
	var item: Item? { get }
}

enum GenericDisplay<T: Equatable>: Equatable, GenericDisplayProtocol, StateContainer {
	case error(error: DataServiceError)
	case display(item: T)
	typealias Item = T

	var item: T? {
		guard case let .display(loadedItem) = self
		else {
			return nil
		}
		return loadedItem
	}
}
