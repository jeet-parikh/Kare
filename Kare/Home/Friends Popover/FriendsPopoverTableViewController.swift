//
//  FriendsPopoverTableViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/20/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SCLAlertView
import SkeletonView
import EmptyDataSet_Swift

class FriendsPopoverTableViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "You are not following anyone.",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "noPerson"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        let db = Firestore.firestore()
        
        let friendsPopoverListener = db.collection("friends").document(Auth.auth().currentUser!.uid).addSnapshotListener { (document, error) in
            
            if let error = error {
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                print("Error: \(error)")
            } else {
                self.following = []
                
                let dataDescription = document?.data()
                
                for item in dataDescription!["Following"] as! Array<Any> {
                    self.following.append(item as! String)
                    self.tableView.heightAnchor.constraint(equalToConstant: CGFloat(self.following.count*60)).isActive = true
                    
                    self.tableView.reloadData()
                }
                
                self.tableView.heightAnchor.constraint(equalToConstant: CGFloat(self.following.count*60)).isActive = true
                
                self.tableView.reloadData()
            }
        }
        Constants.allSnapshotListeners.append(friendsPopoverListener)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    var following: [String] = []
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("1")
        let friendCell = tableView.dequeueReusableCell(withIdentifier: "popoverFriendsCell") as! FriendsPopoverTableViewCell
        
        friendCell.view.backgroundColor = .systemBackground
        
        friendCell.showAnimatedSkeleton()
        let uid = following[indexPath.row]
        
        let db = Firestore.firestore()
        let docRef = db.collection("users1").document(uid)
        print("2")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("3")
                let dataDescription = document.data()
                
                friendCell.firstName = dataDescription!["First Name"]! as! String
                friendCell.name.text = "\(dataDescription!["First Name"]!) \(dataDescription!["Last Name"]!)"
                friendCell.uid = uid
                
                print("4")
                let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
                let storageProfileRef = storageRef.child("profile").child(dataDescription!["Email"] as? String ?? "No email found")
                
                storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if error != nil {
                        print("Profile Picture Error: \(String(describing: error?.localizedDescription))")
                        friendCell.profilePicture.image = UIImage(named: "defaultProfilePicture")
                        friendCell.view.backgroundColor = .systemGray5
                        friendCell.hideSkeleton()
                    } else {
                        print("5")
                        friendCell.profilePicture.image = UIImage(data: data!)!
                        friendCell.view.backgroundColor = .systemGray5
                        friendCell.hideSkeleton()
                    }
                }
            }
        }
        
        print("6")
        return friendCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "People who you follow:"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FriendsPopoverTableViewCell
        
        let tab = self.presentingViewController as! UITabBarController
        let nav = tab.selectedViewController as! UINavigationController
        let home = nav.topViewController as! HomeViewController
        
        home.currentUserName = cell.name.text ?? ""
        home.transferUid = cell.uid
        
        home.performSegue(withIdentifier: "segueToViewUserData", sender: home)
        
        self.dismiss(animated: true, completion: nil)
    }
}
