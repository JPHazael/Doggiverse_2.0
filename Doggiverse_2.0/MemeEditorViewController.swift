//
//  MemeEditorViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var memeContext: NSManagedObjectContext {
        return delegate.stack.context
    }
    
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let pickerController = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 28)!,
        NSStrokeWidthAttributeName : -3
        ] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextAttributes(textFieldBottom, textFieldTop)
        
        // check for the camera
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
    }
    
    
    // set up the view will appear and disappear to subscribe and unsub to keyboard notifications
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // check for an image and enable share button if there is an image in the image view
        
        actionButton.isEnabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow)  , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide) , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    // Move the frame up when editing the bottom textfield
    
    
    func keyboardWillShow(_ notification: Notification) {
        if textFieldBottom.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // bring the frame back to its original position
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    
    
    // clear text when user selects a text field
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    // dismiss the keyboard when the user presses return
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // functions for text field delegation and initial text text field conditions
    
    func setTextAttributes(_: UITextField, _: UITextField){
        textFieldTop.defaultTextAttributes = memeTextAttributes
        textFieldBottom.defaultTextAttributes = memeTextAttributes
        
        textFieldTop.textAlignment = .center
        textFieldBottom.textAlignment = .center
        
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
        
        textFieldTop.delegate = self
        textFieldBottom.delegate = self
    }
    
    
    // pick an image from an album
    
    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        pickAnImageFromSource(source: .photoLibrary)
        
    }
    
    // get an image from the camera
    
    @IBAction func getImageFromCamera(_ sender: AnyObject) {
        pickAnImageFromSource(source: .camera)
        
    }
    
    func pickAnImageFromSource(source: UIImagePickerControllerSourceType) {
        // code to pick an image from source
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
        
    }
    
    
    
    // cancel buttons
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func editorDidCancel(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // display image in the UIView
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    // put everything together and create the memedImage
    
    func generateMemedImage() -> UIImage
    {
        toolBar.isHidden = true
        navBar.isHidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        navBar.isHidden = false
        
        return memedImage
    }
    
    
    func save() {
        //populate the Meme struct with the memedImage data
        let memedImage = generateMemedImage()
        
        let memeCD = Meme(memeImage: memedImage, context: memeContext)
        
        memeCD.textFieldTop = textFieldTop.text!
        memeCD.textFieldBottom = textFieldBottom.text!
        memeCD.memedImage = UIImagePNGRepresentation(memedImage) as NSData?
        memeCD.originalImage = UIImagePNGRepresentation(imagePickerView.image!) as NSData?
        
        do{
            try self.delegate.stack.saveContext()
            print("Meme saved to core data!")
        }catch{
            print("There was an error while saving context")
        }
        
    }
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities:nil)
        
        //add the save method to the completion handler and save the image if the completion is successful
        
        controller.completionWithItemsHandler = {
            (activityType: UIActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?)in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        self.present(controller, animated: true, completion:nil)
    }
}
