//
//  AddPostViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage



class AddPostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentUser: User!
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    
    @IBOutlet weak var addPhotoButton: CustomizableButton!
    @IBOutlet weak var postImageView: CustomizableImageView!
    @IBOutlet weak var postTextField: UITextView!
    @IBOutlet weak var postButton: CustomizableButton!
    @IBOutlet weak var charactersLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            
        }) { (error) in
            let alert = SCLAlertView()
            _ = alert.showWarning("Error", subTitle: "\(error.localizedDescription)")
            
        }
        
    }
    
    
    @IBAction func selectPicture(_ sender: UITapGestureRecognizer) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func savePost(_ sender: CustomizableButton) {
        
        var postText: String!
        if let text: String = postTextField.text {
            postText = text
        }else{
            postText = ""
        }
        
        if postImageView.image != nil{
            FirebaseClient.sharedInstance.uploadPost(postImage: postImageView.image!, postText: postText, currentUser: self.currentUser)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
            self.present(vc, animated: true, completion: nil)
        } else{
            let alert = SCLAlertView()
            _ = alert.showWarning("PLEASE ADD AN IMAGE", subTitle: "You must add an image in order to post.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.postImageView.image = image
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        let newLength:Int = NSString(string: textView.text!).length + NSString(string: text).length - range.length
        let remainingChar:Int = 60 - newLength
        
        self.charactersLabel.text = "\(remainingChar)"
        if remainingChar == -1 {
            self.charactersLabel.text = "0"
            self.charactersLabel.textColor = UIColor.red
        }else{
            self.charactersLabel.textColor = UIColor.white
            self.charactersLabel.text = "\(remainingChar)"
            
            
        }
        
        return (newLength > 60) ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Meme"{
            self.postImageView.image = nil
            
        }
    }
    
    
}




extension AddPostViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        postTextField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue:
            80)
    }
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
        
    }
    
    @objc private func hideKeyboardOnTap(){
        self.view.endEditing(true)
        
    }
    
    func setTapGestureRecognizerOnView(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddPostViewController.hideKeyboardOnTap))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
    }
    func setSwipeGestureRecognizerOnView(){
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(AddPostViewController.hideKeyboardOnTap))
        swipDown.direction = .down
        self.view.addGestureRecognizer(swipDown)
    }
    
}
