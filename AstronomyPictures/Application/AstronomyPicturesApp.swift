//
//  AstronomyPicturesApp.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI

@main
struct AstronomyPicturesApp: App {
	let dependencyContainer = AppDIContainer()
    var body: some Scene {
        WindowGroup {
            MainContentView(dependencyContainer: dependencyContainer)
        }
    }
}
