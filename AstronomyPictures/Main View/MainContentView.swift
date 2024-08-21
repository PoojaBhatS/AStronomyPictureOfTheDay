//
//  MainContentView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

// MARK: - Main View
/// The main content view for the app
/// This view Displays the Tab to view the Astrinomy Picture of the day

struct MainContentView: View {

	@StateObject private var viewModel: APODViewModel
	
	init(dependencyContainer: AppDIContainer) {
		_viewModel = StateObject(wrappedValue: APODViewModel(
			dependencies: APODViewModel.Dependencies(networkService: dependencyContainer.apodNetworkService, dataStorage: dependencyContainer.dataStorageService))
		)
	}

	var body: some View {
		TabView {
			APODView(viewModel: viewModel)
				.tabItem {
					Label("APOD", systemImage: "photo")
				}
		}
	}
}
