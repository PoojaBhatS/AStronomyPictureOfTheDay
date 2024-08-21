//
//  AppConfigurations.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation
/// A Protocol that provides the contract for a service that is responsible for setting up necessary configurations
protocol AppConfigurationProviding {
	var apiBaseURL: String { get }
	var apiKey: String { get }
}

/// App configurations are stored here to maintain the constants.

final class AppConfiguration: AppConfigurationProviding {

	private(set) lazy var apiBaseURL: String = {
		guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
			fatalError("ApiBaseURL must not be empty in plist")
		}
		return apiBaseURL
	}()

	private(set) lazy var apiKey: String = {
		guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
			fatalError("ApiKey must not be empty in plist")
		}
		return apiKey
	}()
	
}
