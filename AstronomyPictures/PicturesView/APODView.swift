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
			Group {
				switch viewModel.apod {
					case let .display(state):
						if state.isLoading {
							ProgressView()
								.progressViewStyle(.circular)
								.scaleEffect(2.0)
						}
						else if let item = state.item {
							ScrollView {
								VStack(alignment: .leading) {
									Text(item.title)
										.font(.title)
										.padding()
										.multilineTextAlignment(.leading)
									
									Text(item.date.asMediumFormatDateString)
										.font(.title2)
										.padding()
										.multilineTextAlignment(.leading)
									
									switch item.mediaType {
										case .image:
											if let imageData = item.imageData {
												Image(uiImage: UIImage(data: imageData)!)
													.resizable()
													.aspectRatio(contentMode: .fit)
													.frame(maxWidth: .infinity, alignment: .center)
													.padding(.vertical, 8)
											} else {
												ProgressView()
													.onAppear {
														viewModel.loadImage(from: item.url, date: item.date)
													}
											}
										case .video:
											if let videoURL =  URL(string: item.url) {
												APODMediaPlayerView(url: videoURL)
													.frame(height: 300)
													.frame(maxWidth: .infinity, alignment: .center)
											}
										case .unknown:
											ProgressView()
									}
									
									Text(item.explanation)
										.padding()
								}
							}
						}
					case let .error(error):
						ErrorView(error: error)
							.frame(alignment: .top)
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
						APODDatePickerView(isPresented: $isDatePickerPresented, selectedDate: $selectedDate)
							.onChange(of: selectedDate) { newValue in
								viewModel.loadData(for: newValue)
								isDatePickerPresented.toggle()
							}
					}
				}
			}
			.onAppear {
				viewModel.loadInitially()
			}
		}
	}
}

private struct ErrorView: View {
	let error: DataServiceError
	var body: some View {
		VStack {
			Text(error.title)
				.foregroundColor(.red)
				.font(.title)
				.bold()
			Text(error.message)
				.foregroundColor(.red)
				.font(.title2)
		}
	}
}

private extension Date {
	var asMediumFormatDateString: String {
		return Utilities.mediumDateFormatter.string(from: self)
	}
}

//#Preview {
//    APODView()
//}
