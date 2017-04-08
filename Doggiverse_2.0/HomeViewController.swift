//
//  HomeViewController.swift
//  Doggiverse_2.0
//
//  Created by admin on 2/10/17.
//  Copyright © 2017 JPDaines. All rights reserved.
//

import UIKit
import HMSegmentedControl
import Firebase
import Kingfisher

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    
    
    var currentUser: User!
    var following = [String]()
    var segmentedControl: HMSegmentedControl!
    var usersArray = [User]()
    var postsArray = [Post]()
    var filteredUsersArray = [User]()
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self

        
        weakSelf?.setupSegmentedControl()
        weakSelf?.setUpUsers()
        weakSelf?.setUpSearchBar()
        tableView.tableHeaderView = searchController.searchBar

        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in.")
            } else {
                print("User is signed out.")
            }
        }
        
        
    }
    
    @IBAction func unwinedToHome(storyboardSegue: UIStoryboardSegue) {}
    
    @IBAction func logout(_ sender: AnyObject) {
        
        FirebaseClient.sharedInstance.logoutUser {[weak self] in
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController
            self?.present(loginVC, animated: true, completion: nil)
        }
        
    }
    
    
    func setUpSearchBar(){
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView?.isHidden = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setUpUsers(){
        AppDelegate.instance().showActivityIndicator()
        
        FirebaseClient.sharedInstance.fetchAllUsers { [weak self] (users) in
            
            self?.usersArray = users
            self?.tableView.reloadData()
            AppDelegate.instance().dismissActivityIndicator()
        }
    }
    
    func postFetch(){
        AppDelegate.instance().showActivityIndicator()
        
        
        FirebaseClient.sharedInstance.fetchAllPosts { (posts) in
            self.postsArray = posts
            self.tableView.reloadData()
            AppDelegate.instance().dismissActivityIndicator()
        }
    }
    
    func setupSegmentedControl(){
        
        
        segmentedControl = HMSegmentedControl(frame: CGRect(x: 0, y: 120, width: self.view.frame.size.width, height: 60))
        segmentedControl.sectionTitles = ["Users", "Posts"]
        
        segmentedControl.backgroundColor = .white
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectionIndicatorLocation = .up
        segmentedControl.selectionStyle = .fullWidthStripe
        segmentedControl.selectionIndicatorColor = UIColor.lightGray
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.titleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            NSFontAttributeName : UIFont.systemFont(ofSize: 17)
        ]
        
        segmentedControl.selectedTitleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 0.05439098924, green: 0.1344551742, blue: 0.1884709597, alpha: 1),
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)
        ]
        
        self.view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(HomeViewController.segementedControlAction), for: UIControlEvents.valueChanged)
        
        
    }
    
    func segementedControlAction(){
        weak var weakSelf = self

        
        if segmentedControl?.selectedSegmentIndex == 0{
            
            self.tableView.rowHeight = UITableViewAutomaticDimension
            weakSelf?.setUpSearchBar()
            weakSelf?.setUpUsers()
            
        } else{
            self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
            weakSelf?.postFetch()
            tableView.tableHeaderView?.isHidden = true
        }
    }
    
    
    // MARK: - Search results controller
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text!)
        
    }
    
    func filterContent(searchText:String, scope: String = "ALL")
    {
        self.filteredUsersArray = self.usersArray.filter{ user in
            
            let results = (user.username?.lowercased().contains(searchText.lowercased()))!
            return(results)
            
        }
        
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table View Delegate
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
            cell.configureCellForPost(post: postsArray[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            
            if self.searchController.isActive{
                cell.configureCellForUser(user: filteredUsersArray[indexPath.row])
                
            } else{
                
                cell.configureCellForUser(user: usersArray[indexPath.row])
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if self.searchController.isActive{
                rows = filteredUsersArray.count
            }else{
                rows = usersArray.count
            }
        case 1:
            rows = postsArray.count
        default: break
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            height = 104
        case 1:
            height = 450
        default: break
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            performSegue(withIdentifier: "selectedUser", sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            self.tableView.deselectRow(at: indexPath, animated: true)
        default: break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedUser"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let selectedVC = segue.destination as! SelectedUserProfileViewController
                selectedVC.ref = usersArray[indexPath.row].ref
            }
        }
    }
}
