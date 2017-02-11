//
//  SelectedUserProfileViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import Firebase
import Kingfisher

class SelectedUserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var selectedUserImageView: CustomizableImageView!
    @IBOutlet weak var selectedUserTableView: UITableView!
    @IBOutlet weak var usernameTextField: CustomizableTextfield!
    
    var ref: FIRDatabaseReference!
    var selectedUser: User!
    var postsArray = [Post]()
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedUserTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.selectedUserTableView.rowHeight = 450
        self.fetchSelectedUser()
    }
    
    func fetchSelectedUser(){
        FirebaseClient.sharedInstance.fetchSelectedUserInfo(ref: ref) { (user) in
            
            if user.uid == nil{
                let alert = SCLAlertView()
                _ = alert.showError("OOPS", subTitle: "There was an error fetching the user info.")
            }else{
            
            self.firstNameLabel.text = user.firstName
            self.lastNameLabel.text = user.lastName
            self.usernameTextField.text = "@\(user.username!)"
            
            self.selectedUser = user
            
            let profileResource = ImageResource(downloadURL: URL(string: self.selectedUser.profilePictureURL)!, cacheKey: self.selectedUser.profilePictureURL)
            
            FirebaseClient.sharedInstance.fetchPostsForUser(userID: user.uid, ref: self.databaseRef, completion: { (posts) in
                self.postsArray = posts
                self.selectedUserTableView.reloadData()
            })
            
            
            DispatchQueue.main.async{
                self.selectedUserImageView.kf.indicatorType = .activity
                self.selectedUserImageView.kf.setImage(with: profileResource)
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
