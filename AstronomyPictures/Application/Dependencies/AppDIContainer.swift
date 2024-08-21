//
//  AppDIContainer.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

final class AppDIContainer: ObservableObject {
	
	lazy var appConfiguration: AppConfigurationProviding = {
		return AppConfiguration()
	}()

	lazy var dataStorageService: APODDataManager = {
		return APODDataManager.shared
	}()

	// MARK: - Network
	lazy var apodNetworkService: APODNetworkServiceProviding = {
		let networkService = NetworkService(session: .shared)
		return APODNetworkService(appConfiguration: appConfiguration, networkService: networkService)
	}()
}

