//
//  FriendTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/8/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SCLAlertView

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    
    var uid: String = ""
    var followingOrFollowers: Int = 0 // var set to 0 for Followers tab and set to 1 for Following tab
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        if followingOrFollowers == 0 {
            // Followers
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            
            alert.addButton("Yes") {
                let db = Firestore.firestore()
                
                //  Remove friend from current user's pending friends
                let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
                friendDocRef.updateData([
                    "Followers": FieldValue.arrayRemove([self.uid])
                ])
                
                // Add request to other user's firestore
                let requestDocRef = db.collection("friends").document(self.uid)
                requestDocRef.updateData([
                    "Following": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
                ]) 
            }
            
            alert.addButton("No") {
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.showWarning("Are you sure you want to remove this person as a follower?", subTitle: "They will no longer have access to your shared data")
        }
        
        if followingOrFollowers == 1 {
            // Following
            
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            
            alert.addButton("Yes") {
                let db = Firestore.firestore()
                
                //  Remove friend from current user's pending friends
                let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
                friendDocRef.updateData([
                    "Following": FieldValue.arrayRemove([self.uid])
                ])
                
                // Add request to other user's firestore
                let requestDocRef = db.collection("friends").document(self.uid)
                requestDocRef.updateData([
                    "Followers": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
                ])
            }
            
            alert.addButton("No") {
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.showWarning("Are you sure you want to un-follow this person?", subTitle: "You will lose access to their data")
        }
    }
}
