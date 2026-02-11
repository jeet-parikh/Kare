//
//  UserTableViewCell.swift
//  Kare
//
//  Created by Niraj Parikh on 3/29/21.
//

import UIKit
import SCLAlertView
import FirebaseFirestore
import FirebaseAuth
 
class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    var uid: String = ""
    var label: String = "Add friend"
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        
        if addFriendButton.titleLabel?.text == "Follower" {
            SCLAlertView().showSuccess("\(name.text!) is already a follower", subTitle: "")
            
        } else if addFriendButton.titleLabel?.text == "Request Sent" {
            SCLAlertView().showInfo("This is a pending request", subTitle: "\(name.text!) will have to accept your request")
            
        } else {
            
            addFriendButton.setTitle("Request Sent", for: .normal)
            addFriendButton.setTitleColor(.white, for: .normal)
            addFriendButton.backgroundColor = .systemGreen
            
            // send friend request
            let db = Firestore.firestore()
            
            // Add request to current user's pending friends
            let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
            friendDocRef.updateData([
                "Pending Friends": FieldValue.arrayUnion([uid])
            ])
            
            // Add request to other user's firestore
            let requestDocRef = db.collection("friends").document(uid)
            requestDocRef.updateData([
                "Friend Requests": FieldValue.arrayUnion([Auth.auth().currentUser?.uid])
            ])
            
            // Present success message
            SCLAlertView().showSuccess("Request Sent", subTitle: "\(name.text!) will have to accept your request")
        }
        
    }
    
    func showError(_ message: String) {
        SCLAlertView().showError("Error", subTitle: message)
    }
}
