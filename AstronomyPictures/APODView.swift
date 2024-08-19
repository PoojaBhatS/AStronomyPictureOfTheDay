//
//  APODView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

struct APODView: View {
	@ObservedObject var viewModel: APODViewModel
	@State private var isDatePickerPresented = false
	@State private var selectedDate = Date()
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					if let apod = viewModel.apod {
						Text(apod.title)
							.font(.title)
							.padding()
							.multilineTextAlignment(.leading)
						
						Text(viewModel.formatDate(selectedDate))
							.font(.title2)
							.padding()
							.multilineTextAlignment(.leading)
						
						if apod.mediaType == "image" {
							AsyncImage(url: URL(string: apod.url)) { image in
								image
									.resizable()
									.scaledToFit()
								
							} placeholder: {
								ProgressView()
							}
							.frame(maxHeight: 300)
						} else if apod.mediaType == "video" {
							APODMediaPlayerView(url: URL(string: apod.url)!)
								.frame(height: 300)
						}
						
						Text(apod.explanation)
							.padding()
					} else if let errorMessage = viewModel.errorMessage {
						Text(errorMessage)
							.foregroundColor(.red)
					} else {
						ProgressView()
					}
				}
			}
			
			.navigationTitle("NASA APOD")
			.navigationBarTitleDisplayMode(.automatic)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						isDatePickerPresented.toggle()
					}) {
						Image(systemName: "calendar")
					}
					.sheet(isPresented: $isDatePickerPresented) {
						APODDatePickerView(isPresented: $isDatePickerPresented, selectedDate: $selectedDate, viewModel: viewModel)
					}
				}
			}
			.onAppear {
				Task {
					await viewModel.fetchAPOD()
				}
			}
		}
	}
}

//#Preview {
//    APODView()
//}
