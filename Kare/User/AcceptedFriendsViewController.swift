//
//  AcceptedFriendsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/7/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import BadgeHub
import SCLAlertView
import EmptyDataSet_Swift
import SkeletonView

class AcceptedFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constants.Theme.themeColor
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance =  appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "You do not have any followers. \n\nClick the icon in the top right corner to add someone!",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "noPerson"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        friendOrRequestsSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
    }
    
    @IBOutlet weak var badgeView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        let hub = BadgeHub(view: badgeView)
        let db = Firestore.firestore()
        
        let threePanelFriendListener = db.collection("friends").document(Auth.auth().currentUser!.uid).addSnapshotListener { (document, error) in
            
            if let error = error {
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                print("Error: \(error)")
            } else {
                self.followers = []
                self.following = []
                self.requestList = []
                
                let dataDescription = document?.data()
                
                for item in dataDescription!["Followers"] as! Array<Any> {
                    self.followers.append(item as! String)
                    self.tableView.reloadData()
                }
                
                for item in dataDescription!["Following"] as! Array<Any> {
                    self.following.append(item as! String)
                    self.tableView.reloadData()
                }
                
                for item in dataDescription!["Friend Requests"] as! Array<Any> {
                    
                    self.requestList.append(item as! String)
                    self.tableView.reloadData()
                }
                
                self.tableView.reloadData()
                
                if let requests = dataDescription!["Friend Requests"] as? Array<String> {
                    if requests.count == 0 {
                        
                        hub.setCount(0)
                        hub.hide()
                    } else {
                        hub.setCount(requests.count)
                        hub.show()
                        hub.bump()
                    }
                }
            }
        }
        Constants.allSnapshotListeners.append(threePanelFriendListener)
    }
    
    @IBOutlet weak var friendOrRequestsSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    
    
    var requestList: [String] = []
    
    var followers: [String] = []
    var following: [String] = []
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        friendOrRequestsSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        if friendOrRequestsSegmentControl.selectedSegmentIndex == 0 {
            self.navigationItem.title = "Followers"
            infoLabel.text = "THEY can access YOUR data"
            
            tableView.emptyDataSetView { view in
                view.titleLabelString(
                    NSAttributedString(
                        string: "You do not have any followers. \n\nClick the icon in the top right corner to add someone!",
                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                    )
                )
                    .image(UIImage(named: "noPerson"))
                    .shouldFadeIn(true)
                    .isTouchAllowed(true)
            }
            
            tableView.reloadData()
            
        } else if friendOrRequestsSegmentControl.selectedSegmentIndex == 1 {
            self.navigationItem.title = "Following"
            infoLabel.text = "YOU can access THEIR data"
            
            tableView.emptyDataSetView { view in
                view.titleLabelString(
                    NSAttributedString(
                        string: "You are currently not following anyone.",
                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                    )
                )
                    .image(UIImage(named: "noPerson"))
                    .shouldFadeIn(true)
                    .isTouchAllowed(true)
            }
            
            tableView.reloadData()
            
        } else {
            self.navigationItem.title = "Requests"
            infoLabel.text = "THEY want YOU to have access to THEIR data"
            
            tableView.emptyDataSetView { view in
                view.titleLabelString(
                    NSAttributedString(
                        string: "Nobody has requested to add you as a follower.",
                        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                    )
                )
                    .image(UIImage(named: "noPerson"))
                    .shouldFadeIn(true)
                    .isTouchAllowed(true)
            }
            
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendOrRequestsSegmentControl.selectedSegmentIndex == 0 {
            return followers.count
        } else if friendOrRequestsSegmentControl.selectedSegmentIndex == 1 {
            return following.count
        } else {
            return requestList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell = UITableViewCell()
        
        if friendOrRequestsSegmentControl.selectedSegmentIndex == 0 {
            // Followers
            
            let friendCell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell") as! FriendTableViewCell
            friendCell.profilePicture.layer.cornerRadius = friendCell.profilePicture.frame.height/2
            friendCell.followingOrFollowers = 0
            
            friendCell.showAnimatedSkeleton()
            
            let uid = followers[indexPath.row]
            
            let db = Firestore.firestore()
            let docRef = db.collection("users1").document(uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    
                    friendCell.email.text = dataDescription!["Email"] as? String
                    friendCell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                    friendCell.uid = uid
                    
                    let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                    let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                    
                    storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                            friendCell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            friendCell.hideSkeleton()
                        } else {
                            friendCell.profilePicture.image = UIImage(data: data!)!
                            friendCell.hideSkeleton()
                        }
                    }
                }
            }
            returnCell = friendCell
            
        } else if friendOrRequestsSegmentControl.selectedSegmentIndex == 1 {
            // Following
            print("1")
            let friendCell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell") as! FriendTableViewCell
            friendCell.profilePicture.layer.cornerRadius = friendCell.profilePicture.frame.height/2
            friendCell.followingOrFollowers = 1
            
            friendCell.showAnimatedSkeleton()
            
            let uid = following[indexPath.row]
            
            let db = Firestore.firestore()
            let docRef = db.collection("users1").document(uid)
            print("2")
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    print("3")
                    let dataDescription = document.data()
                    
                    friendCell.email.text = dataDescription!["Email"] as? String
                    friendCell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                    friendCell.uid = uid
                    print("4")
                    let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                    let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                    
                    storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                            friendCell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            friendCell.hideSkeleton()
                            
                        } else {
                            print("5")
                            friendCell.profilePicture.image = UIImage(data: data!)!
                            friendCell.hideSkeleton()
                        }
                    }
                }
            }
            print("6")
            returnCell = friendCell
            
        } else {
            // Requests
            
            let requestCell = tableView.dequeueReusableCell(withIdentifier: "Recieved Cell") as! RequestRecievedTableViewCell
            requestCell.profilePicture.layer.cornerRadius = requestCell.profilePicture.frame.height/2
            
            requestCell.acceptButton.layer.cornerRadius = requestCell.acceptButton.frame.height/4
            
            requestCell.deleteButton.layer.cornerRadius = requestCell.deleteButton.frame.height/4
            
            requestCell.showAnimatedSkeleton()
            
            let uid = requestList[indexPath.row]
            
            let db = Firestore.firestore()
            let docRef = db.collection("users1").document(uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    
                    requestCell.email.text = dataDescription!["Email"] as? String
                    requestCell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                    requestCell.uid = uid
                    
                    let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                    let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                    
                    storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                            requestCell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            requestCell.hideSkeleton()
                            
                        } else {
                            requestCell.profilePicture.image = UIImage(data: data!)!
                            requestCell.hideSkeleton()
                        }
                    }
                }
            }
            returnCell = requestCell
            
        }
        print("7")
        return returnCell
    }
}

