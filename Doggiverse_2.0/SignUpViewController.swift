//
//  SignUpViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var signedUp: Bool!
    var countryArrays: [String] = []
    var pickerView: UIPickerView!
    var memeContext: NSManagedObjectContext {
        return delegate.stack.context
    }
    
    
    
    @IBOutlet weak var usernameTextField: CustomizableTextfield! {
        didSet{
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var emailTextField: CustomizableTextfield! {
        didSet{
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: CustomizableTextfield!{
        didSet{
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var reenterPasswordTextField: CustomizableTextfield! {
        didSet{
            reenterPasswordTextField.delegate = self
        }
    }
    @IBOutlet weak var firstnameTextField: CustomizableTextfield!{
        didSet{
            firstnameTextField.delegate = self
        }
    }
    @IBOutlet weak var lastnameTextField: CustomizableTextfield! {
        didSet{
            lastnameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var countryTextField: CustomizableTextfield!{
        didSet{
            countryTextField.delegate = self
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBOutlet weak var createAccountButton: CustomizableButton!
    @IBOutlet weak var userProfileImageView: CustomizableImageView!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTapGestureRecognizerOnView()
        setSwipeGestureRecognizerOnView()
        getCountries()
        setCountryPickerView()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [UIColor.black.cgColor,UIColor.lightGray.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor]
        
        gradient.locations = [0.12,0.5, 0.75, 1.0]
        
        view.layer.insertSublayer(gradient, at: 0)
        
    }
    
    @IBAction func createAccountAction(_ sender: CustomizableButton) {
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = passwordTextField.text!
        let reenterPassword = reenterPasswordTextField.text!
        let firstname = firstnameTextField.text!
        let lastname = lastnameTextField.text!
        let country = countryTextField.text!
        
        
        let userCD = UserProfile(username: usernameTextField.text!, context: memeContext)
        userCD.email = email
        userCD.password = password
        userCD.username = usernameTextField.text!
        
        do{
            try self.delegate.stack.saveContext()
            print("User profile saved to core data!")
        }catch{
            print("There was an error while saving context")
        }
        
        
        let imgData = UIImageJPEGRepresentation(userProfileImageView.image!, 0.2)
        
        if finalEmail.isEmpty || password.isEmpty || reenterPassword.isEmpty || firstname.isEmpty || lastname.isEmpty || country.isEmpty {
            let alert = SCLAlertView()
            _ = alert.showWarning("OOPS", subTitle: "One or more fields have not been filled. Please try again.")
        }else {
            
            if password == reenterPassword {
                
                print("valid email")

                FirebaseClient.sharedInstance.signUp(firstName: firstname, lastName: lastname, country: country, password: password, email: finalEmail, profilePictureData: imgData!, username: usernameTextField.text!, completion: { (success) in
                    if success{
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            } else {
                let alert = SCLAlertView()
                _ = alert.showError("OOPS", subTitle: "There was an error signing up. Please try again.")
            }
            
        }
        
        self.view.endEditing(true)
    }
    
}

extension SignUpViewController {
    
    func getCountries(){
        
        for code in NSLocale.isoCountryCodes as [String]{
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_EN").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            
            countryArrays.append(name)
            countryArrays.sort(by: { (name1, name2) -> Bool in
                name1 < name2
            })
        }
    }
    
    func setCountryPickerView(){
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.black
        countryTextField.inputView = pickerView
    }
    
    
    @IBAction func choosePictureAction(_ sender: UITapGestureRecognizer) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.popoverPresentationController?.delegate = self
        pickerController.popoverPresentationController?.sourceView = userProfileImageView
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
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userProfileImageView.image = chosenImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        reenterPasswordTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        return true
    }
    
    func passwordIsSecure(textfield: UITextField){
        if textfield.isEditing{
            textfield.isSecureTextEntry = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 30)
        passwordIsSecure(textfield: passwordTextField)
        passwordIsSecure(textfield: reenterPasswordTextField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue:
            30)
    }
    
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardOnTap))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    func setSwipeGestureRecognizerOnView(){
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardOnTap))
        swipDown.direction = .down
        self.view.addGestureRecognizer(swipDown)
    }
    
    // MARK: - Country Picker view data source
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArrays[row]
    }
    @objc(numberOfComponentsInPickerView:) func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArrays[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArrays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let title = NSAttributedString(string: countryArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return title
    }
    
    @objc(pickerView:viewForRow:forComponent:reusingView:) func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 20)
        label.text = countryArrays[row]
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
}
