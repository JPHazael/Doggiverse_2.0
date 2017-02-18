//
//  Post.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var author: String!
    var imagePath: String!
    var likes: Int!
    var postID: String!
    var postText: String!
    var userID: String!
    var flags: Int!
    var username: String!
    var profilePictureURL: String!
    var postAge: String!
    
    var usersWhoLike: [String] = [String]()
    var usersWhoFlag: [String] = [String]()
}
