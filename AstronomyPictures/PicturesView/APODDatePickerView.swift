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
	
	var body: some View {
		NavigationView {
			VStack() {
				DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
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

//#Preview {
//	APODDatePickerView(isPresented: true, selectedDate: <#Binding<Date>#>, viewModel: <#APODViewModel#>)
//}
