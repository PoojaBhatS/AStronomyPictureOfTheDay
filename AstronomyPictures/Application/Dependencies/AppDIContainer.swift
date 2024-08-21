//
//  AppDIContainer.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

/// A Class that provides single point of access for all Dependencies

final class AppDIContainer {
	
	// MARK: - Configuration
	lazy var appConfiguration: AppConfigurationProviding = {
		return AppConfiguration()
	}()

	// MARK: - Data Storage
	lazy var dataStorageService: APODDataManagerProviding = {
		return APODDataManager.shared
	}()

	// MARK: - Network
	lazy var apodNetworkService: APODNetworkServiceProviding = {
		let networkService = NetworkService(session: .shared)
		return APODNetworkService(appConfiguration: appConfiguration, networkService: networkService)
	}()
}

