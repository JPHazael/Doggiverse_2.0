//
//  UserTableViewCell.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class UserTableViewCell: UITableViewCell {
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    func configureCellForUser(user: User){
        
        self.username.text = user.getFullName()
        self.usernameLabel.text = "@\(user.username!)"
        self.countryLabel.text = user.country
        
        let userResource = ImageResource(downloadURL: URL(string: user.profilePictureURL)!, cacheKey: user.profilePictureURL)
        DispatchQueue.main.async {
            self.userImageView.kf.indicatorType = .activity
            self.userImageView.kf.setImage(with: userResource)
        }
        
    }
}
