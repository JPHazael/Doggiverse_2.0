//
//  LoginViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import CoreData
import Firebase



class LoginViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var memeContext: NSManagedObjectContext {
        return delegate.stack.context
    }
    override var prefersStatusBarHidden: Bool {
        return true
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
    @IBOutlet weak var forgotDetailButton: UIButton!
    @IBOutlet weak var signInButton: CustomizableButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGestureRecognizerOnView()
        setSwipeGestureRecognizerOnView()
        self.loadUserInfo()
        let gradient = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.darkGray.cgColor, UIColor.white.cgColor]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in.")
            } else {
                print("User is signed out.")
            }
        }
        
    }
    

    func loadUserInfo() {
        
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        
        do {
            let searchResults = try memeContext.fetch(request)
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for profile in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                if profile.value(forKey: "email") != nil{
                    emailTextField.text = profile.value(forKey: "email")! as? String
                    passwordTextField.isSecureTextEntry = true
                    passwordTextField.text = profile.value(forKey: "password")! as? String
                }
            }
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!) { error in
            if self.emailTextField.text != nil{
                let alert = SCLAlertView()
                _ = alert.showWarning("No worries", subTitle: "We've sent you an Email with password reset instructions")
                
            } else{
                let alert = SCLAlertView()
                _ = alert.showWarning("OOPS", subTitle: "We weren't able to send you a new password. Please try again.")
            }
        }
        
    }
    
    
    
    
    @IBAction func signInAction(_ sender: CustomizableButton) {
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty {
            let alert = SCLAlertView()
            _ = alert.showWarning("Please fill in all the fields!", subTitle: "One or more fields have not been filled. Please try again.")
        }else {
            
            FirebaseClient.sharedInstance.signIn(email: finalEmail, password: password, completion: { (success) in
                if success == true{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
                    self.present(vc, animated: true, completion: nil)
                }
            })
        }
        self.view.endEditing(true)
    }
    
}

extension LoginViewController {
    
    @IBAction func unwindToLogin(_ storyboardSegue: UIStoryboardSegue){}
    
    private func hideForgotDetailButton(isHidden: Bool){
        self.forgotDetailButton.isHidden = isHidden
    }
    
    func passwordIsSecure(textfield: UITextField){
        if textfield.isEditing{
            textfield.isSecureTextEntry = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
        hideForgotDetailButton(isHidden: true)
        passwordIsSecure(textfield: passwordTextField)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue:
            80)
        hideForgotDetailButton(isHidden: false)
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboardOnTap))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
    }
    func setSwipeGestureRecognizerOnView(){
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboardOnTap))
        swipDown.direction = .down
        self.view.addGestureRecognizer(swipDown)
    }
}
