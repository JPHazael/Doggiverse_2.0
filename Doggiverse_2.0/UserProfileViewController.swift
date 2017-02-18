//
//  UserProfileViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var ref: FIRDatabaseReference!
    var selectedUser: User!
    var postsArray = [Post]()
    
    @IBOutlet weak var userProfileImageView: CustomizableImageView!
    @IBOutlet weak var firstNameTextField: CustomizableTextfield!
    @IBOutlet weak var lastNameTextField: CustomizableTextfield!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var currentUserTableView: UITableView!
    @IBOutlet weak var usernameTextField: CustomizableTextfield!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        
        self.currentUserTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.currentUserTableView.rowHeight = 450
    }
    
    
    
    func fetchCurrentUser(){
        AppDelegate.instance().showActivityIndicator()
        
        FirebaseClient.sharedInstance.fetchCurrentUserInfo { (user) in
            
            self.selectedUser = user
            
            if user.uid == nil{
                let alert = SCLAlertView()
                _ = alert.showError("OOPS", subTitle: "There was an error fetching the user info.")
            }else{
 
            
            self.countryLabel.text = user.country
            self.emailLabel.text = user.email
            self.firstNameTextField.text = user.firstName
            self.lastNameTextField.text = user.lastName
            self.usernameTextField.text = "@\(user.username!)"
            
            let profileResource = ImageResource(downloadURL: URL(string: self.selectedUser.profilePictureURL)!, cacheKey: self.selectedUser.profilePictureURL)
            
            FirebaseClient.sharedInstance.fetchPostsForUser(userID: user.uid, ref: self.databaseRef, completion: { (posts) in
                self.postsArray = posts
                self.currentUserTableView.reloadData()
            })
            
            DispatchQueue.main.async {
                self.userProfileImageView.kf.indicatorType = .activity
                self.userProfileImageView.kf.setImage(with: profileResource)
                AppDelegate.instance().dismissActivityIndicator()
                }
            }
        }
    }
    
    
    // MARK: - Table View Delegate
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
        
        cell.configureCellForPost(post: postsArray[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.postsArray.count
    }
    
}
