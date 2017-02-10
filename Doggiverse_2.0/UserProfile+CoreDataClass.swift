//
//  UserProfile+CoreDataClass.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import CoreData


public class UserProfile: NSManagedObject {
    
    
    convenience init(username: String, context: NSManagedObjectContext) {
        
        //Core Data
        if let entity = NSEntityDescription.entity(forEntityName: "UserProfile", in: context){
            self.init(entity: entity, insertInto: context)
            
            
            
        } else {
            fatalError("Unable to find entity name!")
        }
    }
    
}
