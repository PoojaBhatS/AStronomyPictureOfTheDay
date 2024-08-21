//
//  AppConfigurations.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

protocol AppConfigurationProviding {
	var apiBaseURL: String { get }
	var apiKey: String { get }
}

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
