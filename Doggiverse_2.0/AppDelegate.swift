//
//  AppDelegate.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!
    var reachability: Reachability?

    
    class func instance() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showActivityIndicator(){
        if let window = window{
            container = UIView()
            container.frame = window.frame
            container.center = window.center
            container.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.center = CGPoint(x: container.frame.size.width / 2, y: container.frame.size.height / 2)
            
            container.addSubview(activityIndicator)
            window.addSubview(container)
            
            activityIndicator.startAnimating()
        }
    }
    
    func dismissActivityIndicator(){
        if window != nil{
            container.removeFromSuperview()
        }
        
        
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 16/255.0, green: 171/255.0, blue: 235/255.0, alpha: 1.0)], for: UIControlState.selected)
        FIRApp.configure()
        
        //Enable data persistence for when if the user goes offline or has connection issues.
        FIRDatabase.database().persistenceEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.checkForReachability), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        self.reachability = Reachability.forInternetConnection()
        self.reachability!.startNotifier()
        
        
        
        return true
    }
    
    func checkForReachability(notification: Notification){
        
        let remoteHostStatus = self.reachability!.currentReachabilityStatus()
        
        if remoteHostStatus == NotReachable{
        DispatchQueue.main.async{
            let alert = SCLAlertView()
            _ = alert.showError("OOPS", subTitle: "It Appears you have lost your internet connection. This my affect the performance of the app.")
            
            }
        }
    }
    
}

