//
//  LikeEntity+CoreDataProperties.swift
//  TestProject
//
//  Created by AI on 19.11.2025.
//

public import Foundation
public import CoreData

public typealias LikeEntityCoreDataPropertiesSet = NSSet

extension LikeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LikeEntity> {
        return NSFetchRequest<LikeEntity>(entityName: "LikeEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var postId: Int16
    @NSManaged public var userId: String?
    @NSManaged public var createdAt: Date?
}

extension LikeEntity: Identifiable {

}
