//
//  APODEntity+CoreDataProperties.swift
//  AstronomyPictures
//
//  Created by Pooja on 21/08/2024.
//
//

import Foundation
import CoreData


extension APODEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APODEntity> {
        return NSFetchRequest<APODEntity>(entityName: "APODEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var explanation: String?
    @NSManaged public var image: Data?
    @NSManaged public var mediaType: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}

extension APODEntity : Identifiable {

}
