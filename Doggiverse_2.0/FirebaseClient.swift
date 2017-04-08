//
//  FirebaseClient.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseClient{
    
    static let sharedInstance = FirebaseClient()
    let storage = FIRStorage.storage().reference(forURL: "gs://doggiversetwopointoh.appspot.com")
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference!{
        return FIRStorage.storage().reference()
    }
    
    var userStorage: FIRStorageReference!{
        return  storage.child("Users")
        
    }
    
    func signUp(firstName: String, lastName: String, country: String, password: String, email: String, profilePictureData: Data, username: String, completion: @escaping(Bool) -> Void){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error{
                
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                
            } else{
                completion(true)

                self.setUserToDatabase(user: user, firstName: firstName, lastName: lastName, country: country, password: password, profilePictureData: profilePictureData, username: username, completion: { (success) in
                    if success {
                        self.saveUserInfoToDatabase(user: user, firstName: firstName, lastName: lastName, country: country, password: password, username: username, completion: { (success) in
                            if success{
                                self.signIn(email: user!.email!, password: password) { (success) in
                                 if success{
                                 print("user \(firstName) \(lastName) has been signed in!!!")
                                    completion(true)
                                    }
                                 }
                            }
                        })
                    }
                })
                }
            })
        }
    
    func setUserToDatabase(user: FIRUser!,firstName: String, lastName: String, country: String, password: String, profilePictureData: Data, username: String, completion: @escaping(Bool) -> Void){
        
        
        let metadata = FIRStorageMetadata()
        let profilePictureRef = self.userStorage.child("\(user.uid).jpg")
        metadata.contentType = "image/jpeg"
        profilePictureRef.put(profilePictureData, metadata: nil) { (newMD, error) in
            
            
            if let error = error{
                
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                
            } else{
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                if let url = newMD?.downloadURL(){
                    changeRequest.photoURL = url
                }
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error{
                        
                        let alert = SCLAlertView()
                        _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                        
                    } else{
                        completion(true)

                        }
                    })
                }
            }
        }
    
    
    
    func saveUserInfoToDatabase(user: FIRUser!,firstName: String, lastName: String, country: String, password: String, username: String, completion: @escaping(Bool) -> Void){
    
        let userRef = databaseRef.child("users").child(user.uid)
        let newUser = User(email: user.email!, firstName: firstName, lastName: lastName, uid: user.uid, profilePictureURL: String(describing: user.photoURL!), country: country, username: username)
        userRef.setValue(newUser.toAnyObject()) { (error, ref) in
            if let error = error{
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                
            } else{
                print ("user \(firstName) \(lastName) has been signed up!!!")
            }
        }
        completion(true)
    }
    
    
    func signIn(email: String, password: String, completion: @escaping(Bool) -> Void){
    
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error{
                
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                completion(false)
                
            } else{
                if let user = user{
                    print("\(user.displayName) has signed in!")
                    completion(true)
                }
            }
        })
    }
    
    func logoutUser(completion:() -> ()){
        
        try! FIRAuth.auth()!.signOut()
        completion()
    }

    func fetchAllPosts(completion: @escaping([Post]) -> Void){
        var resultsArray = [Post]()
        let ref = FIRDatabase.database().reference()

        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with:{ snap in
            
            let posts = snap.value as! [String: AnyObject]
            for (_, post) in posts{
                
                let displayedPost = Post()
                if let author = post["author"] as? String, let imagePath = post["imagePath"] as? String, let likes = post["likes"] as? Int, let postText = post["postText"] as? String, let userID = post["userID"] as? String, let postID = post["postID"] as? String, let flags = post["flags"] as? Int, let username = post["username"] as? String, let profilePictureURL = post["profilePictureURL"] as? String, let postAge = post["postAge"] as? String  {
                    
                    displayedPost.author = author
                    displayedPost.imagePath = imagePath
                    displayedPost.likes = likes
                    displayedPost.postText = postText
                    displayedPost.userID = userID
                    displayedPost.postID = postID
                    displayedPost.profilePictureURL = profilePictureURL
                    displayedPost.flags = flags
                    displayedPost.username = username
                    displayedPost.postAge = postAge
                    
                    resultsArray.append(displayedPost)
                    completion(resultsArray)
                    
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func fetchPostsForUser(userID: String, ref: FIRDatabaseReference, completion: @escaping([Post]) -> Void){
        
        var resultsArray = [Post]()
        let uid = userID
    
        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with:{ snap in
            
            let posts = snap.value as! [String: AnyObject]
            for (_, post) in posts{
                if uid == (post["userID"] as? String)!{
                    
                    let displayedPost = Post()
                    if let author = post["author"] as? String, let imagePath = post["imagePath"] as? String, let likes = post["likes"] as? Int, let postText = post["postText"] as? String, let userID = post["userID"] as? String, let postID = post["postID"] as? String, let flags = post["flags"] as? Int, let username = post["username"] as? String, let profilePictureURL = post["profilePictureURL"] as? String, let postAge = post["postAge"] as? String  {
                        
                        displayedPost.author = author
                        displayedPost.imagePath = imagePath
                        displayedPost.likes = likes
                        displayedPost.postText = postText
                        displayedPost.userID = userID
                        displayedPost.postID = postID
                        displayedPost.profilePictureURL = profilePictureURL
                        displayedPost.flags = flags
                        displayedPost.username = username
                        displayedPost.postAge = postAge
                        
                        resultsArray.append(displayedPost)
                        completion(resultsArray)
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func postWasFlagged(postUID: String, postID: String, completion: @escaping(Bool) -> Void){
        
        if FIRAuth.auth()!.currentUser!.uid == postUID {}
        else{
            
            let ref = FIRDatabase.database().reference()
            
            let keyToPost = ref.child("posts").childByAutoId().key
            ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snapshot in
                
                if (snapshot.value as? [String:AnyObject]) != nil{
                    var updateFlags: [String: Any] = ["peopleWhoFlag/\(keyToPost)": FIRAuth.auth()!.currentUser!.uid]
                    
                    ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snap in
                        if let properties = snap.value as? [String:AnyObject]{
                            
                            if let flags = properties["peopleWhoFlag"] as? [String:AnyObject]{
                                for (_, values) in flags{
                                    let valuesArray = [values]
                                    for value in valuesArray{
                                        if value as! String == FIRAuth.auth()!.currentUser!.uid{
                                            updateFlags.removeValue(forKey: "peopleWhoFlag/\(keyToPost)")
                                        }
                                    }
                                }
                            }
                        }
                        
                        ref.child("posts").child(postID).updateChildValues(updateFlags, withCompletionBlock: { (error, reff) in
                            if error != nil{
                                let alert = SCLAlertView()
                                _ = alert.showWarning("Error", subTitle: "\(error?.localizedDescription)")
                            }else {
                                ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snap in
                                    if let properties = snap.value as? [String:AnyObject]{
                                        
                                        if let flags = properties["peopleWhoFlag"] as? [String:AnyObject]{
                                            
                                            
                                            let count = flags.count
                                            
                                            let update = ["flags": count]
                                            
                                            
                                            ref.child("posts").child(postID).updateChildValues(update)
                                            completion(true)
                                            ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ ssnap in
                                                if let properties = snap.value as? [String:AnyObject]{
                                                    
                                                    if let flags = properties["peopleWhoFlag"] as? [String:AnyObject]{
                                                        if flags.count == 3{
                                                            let alert = SCLAlertView()
                                                            _ = alert.showWarning("Thank you", subTitle: "This post has been flagged. If a couple more people flag this post, we will remove it.")
                                                            ref.child("posts").child(postID).removeValue()
                                                        } else {
                                                            let alert = SCLAlertView()
                                                            _ = alert.showWarning("Thank you", subTitle: "This post has been flagged. If a couple more people flag this post, we will remove it.")
                                                        }
                                                    }
                                                }
                                            })
                                            
                                        }
                                    }
                                })
                            }
                        })
                    })
                }
            })
            ref.removeAllObservers()
        }
    }
    
    func postWasliked(postUID: String, postID: String, completion: @escaping(Int) -> Void){
        
        if FIRAuth.auth()!.currentUser!.uid == postUID {}
        else{
            
            let ref = FIRDatabase.database().reference()
            
            let keyToPost = ref.child("posts").childByAutoId().key
            ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snapshot in
                
                if (snapshot.value as? [String:AnyObject]) != nil{
                    var updateLikes: [String: Any] = ["peopleWhoLike/\(keyToPost)": FIRAuth.auth()!.currentUser!.uid]
                    
                    ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snap in
                        if let properties = snap.value as? [String:AnyObject]{
                            
                            if let likes = properties["peopleWhoLike"] as? [String:AnyObject]{
                                for (_, values) in likes{
                                    let valuesArray = [values]
                                    for value in valuesArray{
                                        if value as! String == FIRAuth.auth()!.currentUser!.uid{
                                            updateLikes.removeValue(forKey: "peopleWhoLike/\(keyToPost)")
                                        }
                                    }
                                }
                            }
                        }
                        
                        ref.child("posts").child(postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                            if error != nil{
                                let alert = SCLAlertView()
                                _ = alert.showWarning("Error", subTitle: "\(error?.localizedDescription)")
                            }else {
                                ref.child("posts").child(postID).observeSingleEvent(of: .value, with:{ snap in
                                    if let properties = snap.value as? [String:AnyObject]{
                                        
                                        if let likes = properties["peopleWhoLike"] as? [String:AnyObject]{
                                            
                                            
                                            let count = likes.count
                                            let update = ["likes": count]
                                            ref.child("posts").child(postID).updateChildValues(update)
                                            
                                            completion(count)
                                        }
                                    }
                                })
                            }
                        })
                    })
                    
                }
            })
            ref.removeAllObservers()
        }
    }
    
    func fetchAllUsers(completion: @escaping([User]) -> Void){
        let usersRef = databaseRef.child("users")
        var resultsArray = [User]()
        
        usersRef.observe(.value, with: { (userSnapshot) in
            
            for user in userSnapshot.children{
                
                let user = User(snapshot: user as! FIRDataSnapshot)
                
                resultsArray.append(user)
                completion(resultsArray)
            }
            
            })
        { (error) in
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
        }
    }
    
    func fetchCurrentUserInfo(completion:@escaping (User) -> ()){
       
        let currentUser = FIRAuth.auth()!.currentUser!
        let currentUserRef =  databaseRef.child("users").child(currentUser.uid)
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            completion(user)
            
            
        }) { (error) in
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
        }
        currentUserRef.removeAllObservers()
    }
    
    
    func fetchSelectedUserInfo(ref: FIRDatabaseReference!, completion:@escaping (User) -> ()){
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            completion(user)
            
            
        }) { (error) in
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
        }
        ref.removeAllObservers()
    }
    
    func uploadPost(postImage: UIImage, postText: String, currentUser: User){
        
        if postImage == postImage {
            AppDelegate.instance().showActivityIndicator()
            
            let imageData = UIImageJPEGRepresentation(postImage, 0.8)
            let imagePath = "PostImage\(FIRAuth.auth()!.currentUser!.uid)/meme.jpg"
            let uid = FIRAuth.auth()!.currentUser!.uid
            
            let key = databaseRef.child("posts").childByAutoId().key
            let storage = FIRStorage.storage().reference(forURL: "gs://doggiversetwopointoh.appspot.com")
            let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
            
            
            var humanReadableAge: String {
                get {
                    let fmt = DateFormatter()
                    fmt.timeStyle = .none
                    fmt.dateStyle = .short
                    fmt.locale = NSLocale.current
                    
                    return fmt.string(from: Date())
                }
            }
            
            
            let uploadTask = imageRef.put(imageData!, metadata: nil, completion: { (newMetaData, error) in
                if error != nil {
                    let alert = SCLAlertView()
                    _ = alert.showWarning("Error", subTitle: "\(error?.localizedDescription)")
                } else{
                
                    
                    
                    imageRef.downloadURL(completion: {(url, error) in
                        if error != nil{
                            let alert = SCLAlertView()
                            _ = alert.showWarning("ERROR", subTitle: "\(error?.localizedDescription)")
                        } else{
                            if let url = url {
                                
                                let feed = ["userID": FIRAuth.auth()!.currentUser!.uid,
                                            "imagePath": url.absoluteString,
                                            "likes": 0,
                                            "flags": 0,
                                            "author": FIRAuth.auth()!.currentUser!.displayName!,
                                            "postText": postText as String,
                                            "postID": key,
                                            "username": currentUser.username,
                                            "profilePictureURL": currentUser.profilePictureURL,
                                            "postAge": humanReadableAge
                                    ] as [String : Any]
                                
                                let postFeed = ["\(key)": feed]
                                
                                self.databaseRef.child("posts").updateChildValues(postFeed)
                                AppDelegate.instance().dismissActivityIndicator()
                            }
                        }
                    })
                }
            })
            
            uploadTask.resume()
        } else {
            let alert = SCLAlertView()
            _ = alert.showWarning("PLEASE ADD AN IMAGE", subTitle: "You must add an image in order to post.")
        }
        
    }
    
    func downloadImage(urlString: String, completion:@escaping (UIImage?) -> ()){
        
        let profilePictureRef = FIRStorage.storage().reference(forURL: urlString)
        profilePictureRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if let error = error {
                let alert = SCLAlertView()
                _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
                
            }else{
                
                DispatchQueue.main.async(execute: {
                    if let data = imgData {
                        completion(UIImage(data: data))
                    }
                })
            }
        })
    }
}
