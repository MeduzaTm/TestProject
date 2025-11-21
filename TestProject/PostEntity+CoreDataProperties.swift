//
//  PostEntity+CoreDataProperties.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 19.11.2025.
//
//

public import Foundation
public import CoreData


public typealias PostEntityCoreDataPropertiesSet = NSSet

extension PostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }

    @NSManaged public var body: String?
    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var userId: Int16

}

extension PostEntity : Identifiable {

}
