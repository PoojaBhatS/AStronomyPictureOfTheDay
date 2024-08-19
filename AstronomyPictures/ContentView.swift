//
//  ContentView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = APODViewModel()
	
	var body: some View {
		TabView {
			APODView(viewModel: viewModel)
				.tabItem {
					Label("APOD", systemImage: "photo")
				}
		}
	}
}
