//
//  UserProfile+CoreDataProperties.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import CoreData

extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile");
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var memes: NSSet?

}

// MARK: Generated accessors for memes
extension UserProfile {

    @objc(addMemesObject:)
    @NSManaged public func addToMemes(_ value: Meme)

    @objc(removeMemesObject:)
    @NSManaged public func removeFromMemes(_ value: Meme)

    @objc(addMemes:)
    @NSManaged public func addToMemes(_ values: NSSet)

    @objc(removeMemes:)
    @NSManaged public func removeFromMemes(_ values: NSSet)

}
