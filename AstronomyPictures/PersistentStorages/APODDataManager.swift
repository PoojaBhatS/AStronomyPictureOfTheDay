//
//  APODDataManager.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

import CoreData
import Foundation

/// A Protocol that defines the contract for a service that is responsible for loading
/// and storing persistent data related to Astronomy Picture Of the Day(APOD)
/// from a persistent source
protocol APODDataManagerProviding {
	func fetchAPODFor(date: Date, completionHandler: @escaping (APODData?, Error?) -> Void)
	func storeAPOD(data: APODData)
	func storeAPODImage(imageData: Data, date: Date)
}

/// Main data manager to handle the APOD storage
/// A class that conforms to `APODDataManagerProviding` for handling data loading
/// and storing into persistent data storage

final class APODDataManager: APODDataManagerProviding {
	
	static let shared = APODDataManager()

	// Add the Core Data container with the model name
	private let container: NSPersistentContainer
	
	// init method. Load the Core Data container
	private init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "APODPersistentStorageModel")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	//MARK: -Data storage to Core data
	
	/// Function to store the APOD to coredata
	/// - Parameter data: object of type `APODData`
	func storeAPOD(data: APODData) {
		var dataToStore: APODEntity
		
		let predicate = NSPredicate(format: "date == %@", data.date as CVarArg)
		let request = APODEntity.fetchRequest()
		
		request.fetchLimit = 1
		request.predicate = predicate
		do {
			let result = try container.viewContext.fetch(request)
			if !result.isEmpty, let existingAPOD = result.first {
				//Update the values from new data if there is an entry
				dataToStore = existingAPOD
			} else {
				//Create new entity entry
				dataToStore = APODEntity(context: container.viewContext)
			}
			dataToStore.date = data.date
			dataToStore.explanation = data.explanation
			dataToStore.mediaType = data.mediaType.value
			dataToStore.title = data.title
			dataToStore.url = data.url
			saveContext()
		} catch {
			//Error handling
			print("Failed to create asset")
		}
	}

	/// Function to store the image to coredata
	/// - Parameter imageData: image converted to type Data
	/// - Parameter date: selected date for saving the image data to persistent storage
	func storeAPODImage(imageData: Data, date: Date) {
		var dataToStore: APODEntity
		
		let predicate = NSPredicate(format: "date == %@", date as CVarArg)
		let request = APODEntity.fetchRequest()
		
		request.fetchLimit = 1
		request.predicate = predicate
		do {
			let result = try container.viewContext.fetch(request)
			if !result.isEmpty, let existingAPOD = result.first {
				//Update the values from new data
				dataToStore = existingAPOD
			} else {
				throw DataServiceError.invalidData
			}
			dataToStore.image = imageData
			saveContext()
		} catch {
			//Error handling
			print("Failed to create asset")
		}
	}

	///Function to fetch the APOD from coredata
	/// - Parameter date: object of type `Date` that returns a matching record if present
	func fetchAPODFor(date: Date, completionHandler: @escaping (APODData?, Error?) -> Void) {
		let predicate = NSPredicate(format: "date == %@", date as CVarArg)
		let request = APODEntity.fetchRequest()
		
		request.fetchLimit = 1
		request.predicate = predicate
		
		do {
			let result = try container.viewContext.fetch(request)
			//Update the values from new data
			var apodData: APODData? = nil
			if let existingAPOD = result.first {
				apodData = APODData(
					date: existingAPOD.date ?? Date(),
					explanation: existingAPOD.explanation ?? "",
					title: existingAPOD.title ?? "",
					url: "",
					mediaType: MediaType(rawValue: existingAPOD.mediaType ?? "") ?? .unknown,
					imageData: existingAPOD.image
				)
			}
			completionHandler(apodData, nil)
		} catch {
			completionHandler(nil, error)
		}
	}
	
	private func saveContext() {
		if container.viewContext.hasChanges {
			do {
				try container.viewContext.save()
			} catch {
				print("An error occurred while saving: \(error)")
			}
		}
	}
}
