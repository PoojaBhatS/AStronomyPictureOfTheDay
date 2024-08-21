//
//  APODMediaPlayerView.swift
//  AstronomyPictures
//
//  Created by Pooja on 19/08/2024.
//

import SwiftUI
import WebKit

struct APODMediaPlayerView: UIViewRepresentable {
	let url: URL
	
	func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		uiView.load(request)
	}
}

//#Preview {
//	APODMediaPlayerView(url: <#URL#>)
//}
