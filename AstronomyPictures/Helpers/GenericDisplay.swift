//
//  GenericDisplay.swift
//  AstronomyPictures
//
//  Created by Pooja on 21/08/2024.
//

import Foundation

protocol StateContainer {
	associatedtype Item
}

protocol GenericDisplayProtocol {
	associatedtype Item
	var item: Item? { get }
}
/// a data type responsible for containing a generic state 
enum GenericDisplay<T: Equatable>: Equatable, GenericDisplayProtocol, StateContainer {
	case error(error: DataServiceError)
	case display(item: T)
	typealias Item = T
	
	var item: T? {
		guard case let .display(loadedItem) = self
		else {
			return nil
		}
		return loadedItem
	}
}
