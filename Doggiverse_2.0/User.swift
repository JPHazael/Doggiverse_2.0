//
//  User.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//


import Foundation
import Firebase
import FirebaseDatabase

class User: NSObject {
    
    var email: String!
    var firstName: String!
    var lastName: String!
    var uid: String!
    var country: String?
    var profilePictureURL: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var username: String!
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        firstName = (snapshot.value as? NSDictionary)?["firstName"] as? String
        lastName = (snapshot.value as? NSDictionary)?["lastName"] as? String
        email = (snapshot.value as? NSDictionary)?["email"] as? String
        country = (snapshot.value as? NSDictionary)?["country"] as? String
        uid = (snapshot.value as? NSDictionary)?["uid"] as? String
        profilePictureURL = (snapshot.value as? NSDictionary)?["profilePictureURL"] as? String
        username = (snapshot.value as? NSDictionary)?["username"] as? String
    }
    
    init(email: String, firstName: String, lastName: String, uid: String, profilePictureURL: String, country: String, key: String = "", username: String){
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
        self.profilePictureURL = profilePictureURL
        self.country = country
        self.username = username
        self.ref = FIRDatabase.database().reference()
        
    }
    
    func getFullName() -> String{
        return "\(firstName!) \(lastName!)"
    }
    
    func toAnyObject() -> [String: Any]{
        return ["email": email, "firstName":firstName, "lastName":lastName, "uid": uid, "profilePictureURL": profilePictureURL, "country": country! as String, "username": username! as String]
    }
}
