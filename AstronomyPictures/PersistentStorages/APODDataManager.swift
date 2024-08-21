//
//  APODDataManager.swift
//  AstronomyPictures
//
//  Created by Pooja on 20/08/2024.
//

import Foundation

import CoreData
import Foundation

// Main data manager to handle the todo items
final class APODDataManager {
	
	static let shared = APODDataManager()

	// Add the Core Data container with the model name
	private let container: NSPersistentContainer
	
	// Default init method. Load the Core Data container
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
	
	func storeAPOD(data: APODData) {
		var dataToStore: APODEntity
		
		let predicate = NSPredicate(format: "date == %@", data.date as CVarArg)
		let request = APODEntity.fetchRequest()
		
		request.fetchLimit = 1
		request.predicate = predicate
		do {
			let result = try container.viewContext.fetch(request)
			if !result.isEmpty, let existingAPOD = result.first {
				//Update the values from new data
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
				//Create new entity entry
				throw DataServiceError.unknown
			}
			dataToStore.image = imageData
			saveContext()
		} catch {
			//Error handling
			print("Failed to create asset")
		}
	}

	
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
	
	func saveContext() {
		if container.viewContext.hasChanges {
			do {
				try container.viewContext.save()
			} catch {
				print("An error occurred while saving: \(error)")
			}
		}
	}
}
