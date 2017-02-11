//
//  ImageTableViewCell.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ImageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: CustomizableImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    
    var postID: String!
    var postUID: String!
    
    
    
    
    @IBAction func postWasFlagged(_ sender: AnyObject) {
        self.flagButton.isEnabled = false
        //FirebaseClient.sharedInstance.postWasFlagged(postUID: self.postUID, postID: self.postID)
        FirebaseClient.sharedInstance.postWasFlagged(postUID: self.postUID, postID: self.postID) { (success) in
            if success == false{
                let alert = SCLAlertView()
                _ = alert.showError("OOPS", subTitle: "There was an error flagging this post. Please try again.")
            }
        }
    }
    
    
    @IBAction func postWasLiked(_ sender: AnyObject) {
        
        
        self.likeButton.isEnabled = false
        FirebaseClient.sharedInstance.postWasliked(postUID: self.postUID, postID: self.postID) { (count) in
            self.likeLabel.text = "\(count)"
        }
    }
    
    
    func configureCellForPost(post: Post){
        
        self.fullNameLabel.text = post.author
        self.usernameLabel.text = "@\(post.username!)"
        self.postTimeLabel.text = post.postAge
        self.postTextView.text = post.postText
        self.postID = post.postID
        self.postUID = post.userID
        self.likeLabel.text = "\(post.likes!)"
        
        
        let postResource = ImageResource(downloadURL: URL(string: post.imagePath)!, cacheKey: post.imagePath)
        let profileResource = ImageResource(downloadURL: URL(string: post.profilePictureURL)!, cacheKey: post.profilePictureURL)
        
        DispatchQueue.main.async {
            self.postImageView.kf.indicatorType = .activity
            self.postImageView.kf.setImage(with: postResource)
            self.profileImageView.kf.indicatorType = .activity
            self.profileImageView.kf.setImage(with: profileResource)
            
        }
        
    }
}
