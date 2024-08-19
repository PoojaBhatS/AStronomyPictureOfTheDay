//
//  APODDatePickerView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

struct APODDatePickerView: View {
	@Binding var isPresented: Bool
	@Binding var selectedDate: Date
	@ObservedObject var viewModel: APODViewModel
	
	var body: some View {
		NavigationView {
			VStack {
				DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
					.datePickerStyle(GraphicalDatePickerStyle())
					.padding()
				
				Button("Load APOD") {
					Task {
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd"
						let dateStr = dateFormatter.string(from: selectedDate)
						await viewModel.fetchAPOD(for: dateStr)
						isPresented = false
					}
				}
				.padding()
				
				Spacer()
			}
			.navigationTitle("Select Date")
			.navigationBarItems(trailing: Button("Done") {
				isPresented = false
			})
		}
	}
}

//#Preview {
//	APODDatePickerView(isPresented: true, selectedDate: <#Binding<Date>#>, viewModel: <#APODViewModel#>)
//}
