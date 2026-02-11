//
//  FriendSearchViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/28/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SCLAlertView
import EmptyDataSet_Swift
import SkeletonView

class FriendSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    var followers: [String] = []
    var friendList : [String] = []
    var pendingFriendsUid: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var pendingTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        
        let friendListener = db.collection("friends").document(Auth.auth().currentUser!.uid).addSnapshotListener { (document, error) in
            
            if let error = error {
                print("Error: \(error)")
            } else {
                
                self.pendingFriendsUid = []
                let dataDescription = document?.data()
                if let array = dataDescription!["Pending Friends"] {
                    for item in array as! Array<Any> {
                        self.pendingFriendsUid.append(item as! String)
                        self.pendingTableView.reloadData()
                    }
                }
                self.pendingTableView.reloadData()
                
                self.followers = []
                
                if let array = dataDescription!["Followers"] {
                    for item in array as! Array<Any> {
                        self.followers.append(item as! String)
                    }
                }
            }
        }
        Constants.allSnapshotListeners.append(friendListener)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.emptyDataSetSource = self
        searchTableView.emptyDataSetDelegate = self
        searchTableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "Enter email above to search",
                    attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 25)]
                )
            )
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        pendingTableView.delegate = self
        pendingTableView.dataSource = self
        pendingTableView.emptyDataSetSource = self
        pendingTableView.emptyDataSetDelegate = self
        pendingTableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "No pending requests",
                    attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 25)]
                )
            )
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
    }
    
    //MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count: Int = 0
        
        if tableView == searchTableView {
            count = friendList.count
        }
        if tableView == pendingTableView {
            count = pendingFriendsUid.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var header = String()
        
        if tableView == searchTableView {
            header = "Search Results"
        }
        if tableView == pendingTableView {
            header = "Pending Requests Sent"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell = UITableViewCell()
        
        if tableView == self.searchTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
            
            cell.addFriendButton.layer.borderWidth = 1
            cell.addFriendButton.layer.cornerRadius = cell.addFriendButton.frame.height/4
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            cell.addFriendButton.isHidden = true
            
            cell.showAnimatedSkeleton()
            
            let uid = friendList[indexPath.row]
            
            let db = Firestore.firestore()
            let docRef = db.collection("users1").document(uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    
                    cell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                    cell.uid = uid
                    
                    let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                    let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                    
                    storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                            cell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            cell.hideSkeleton()
                            
                        } else {
                            cell.profilePicture.image = UIImage(data: data!)!
                            cell.hideSkeleton()
                        }
                    }
                    
                    if self.followers.contains(document.documentID) {
                        // already friends
                        cell.addFriendButton.setTitle("Follower", for: .normal)
                        cell.addFriendButton.setTitleColor(.white, for: .normal)
                        cell.addFriendButton.backgroundColor = .systemGreen
                        cell.addFriendButton.layer.borderColor = UIColor.systemGreen.cgColor
                        cell.addFriendButton.isHidden = false
                        
                    } else if self.pendingFriendsUid.contains(document.documentID){
                        // pending request
                        cell.addFriendButton.setTitle("Request Sent", for: .normal)
                        cell.addFriendButton.setTitleColor(.white, for: .normal)
                        cell.addFriendButton.backgroundColor = .systemGreen
                        cell.addFriendButton.layer.borderColor = UIColor.systemGreen.cgColor
                        cell.addFriendButton.isHidden = false
                    } else {
                        // not friends
                        cell.addFriendButton.setTitle("Add follower", for: .normal)
                        cell.addFriendButton.setTitleColor(.systemGreen, for: .normal)
                        cell.addFriendButton.backgroundColor = .systemGreen.withAlphaComponent(0.3)
                        cell.addFriendButton.layer.borderColor = UIColor.systemGreen.cgColor
                        cell.addFriendButton.isHidden = false
                    }
                    
                }
            }
            returnCell = cell
        }
        
        if tableView == self.pendingTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Request Cell", for: indexPath) as! RequestTableViewCell
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            
            cell.showAnimatedSkeleton()
            
            let uid = pendingFriendsUid[indexPath.row]
            
            let db = Firestore.firestore()
            let docRef = db.collection("users1").document(uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    
                    cell.email.text = dataDescription!["Email"] as? String
                    cell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                    cell.uid = uid
                    
                    let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                    let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                    
                    storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                            cell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            cell.hideSkeleton()
                            
                        } else {
                            cell.profilePicture.image = UIImage(data: data!)!
                            cell.hideSkeleton()
                        }
                    }
                }
            }
            returnCell = cell
        }
        
        return returnCell
        
    }
    
}
//MARK: - SearchBar Delegate Methods

extension FriendSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let db = Firestore.firestore()
        
        db.collection("users1").whereField("Email", isEqualTo: searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            .getDocuments() { (querySnapshot, err) in
                if let err = err { 
                    SCLAlertView().showError("Error", subTitle:err.localizedDescription)
                    print("Error getting documents: \(err)")
                } else {
                    
                    self.friendList = []
                    
                    if querySnapshot?.documents.count == 0 {
                        
                        SCLAlertView().showWarning("No matching results", subTitle: "Please enter full email of user")
                        
                        self.searchTableView.reloadData()
                        
                    } else {
                        
                        for document in querySnapshot!.documents {
                            
                            if document.data()["Email"] as! String == Auth.auth().currentUser?.email {
                                SCLAlertView().showWarning("No matching results", subTitle: "You cannot add yourself as a friend")
                                self.searchTableView.reloadData()
                            } else {
                                self.friendList.append(document.documentID)
                                self.searchTableView.reloadData()
                            }
                        }
                    }
                }
            }
        
        searchBar.resignFirstResponder()
    }
}

