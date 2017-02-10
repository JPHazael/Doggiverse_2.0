//
//  Meme+CoreDataProperties.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import CoreData

extension Meme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meme> {
        return NSFetchRequest<Meme>(entityName: "Meme");
    }

    @NSManaged public var memedImage: NSData?
    @NSManaged public var originalImage: NSData?
    @NSManaged public var textFieldBottom: String?
    @NSManaged public var textFieldTop: String?
    @NSManaged public var user: UserProfile?

}
