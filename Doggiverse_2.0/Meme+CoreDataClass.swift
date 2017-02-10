//
//  Meme+CoreDataClass.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Meme: NSManagedObject {
    
    
    convenience init(memeImage: UIImage, context: NSManagedObjectContext) {
        
        //Core Data
        if let entity = NSEntityDescription.entity(forEntityName: "Meme", in: context){
            self.init(entity: entity, insertInto: context)
            
            
            
        } else {
            fatalError("Unable to find entity name!")
        }
    }
    
}
