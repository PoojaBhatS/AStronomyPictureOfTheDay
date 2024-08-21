//
//  APODDatePickerView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

/// A Custom view with Date Picker Component
struct APODDatePickerView: View {
	@Binding var isPresented: Bool
	@Binding var selectedDate: Date
	
	var body: some View {
		NavigationView {
			VStack() {
				DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
					.datePickerStyle(GraphicalDatePickerStyle())
					.padding()
					.frame(alignment: .top)
			}
			.navigationTitle("Select Date")
			.navigationBarItems(trailing: Button("Dismiss") {
				isPresented = false
			})
		}
	}
}
