//
//  RequestRecievedTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/8/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SCLAlertView

class RequestRecievedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var uid: String = ""
    
    @IBAction func acceptPressed(_ sender: Any) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Yes") {
            let db = Firestore.firestore()
            
            //  Add friend to current user's friends
            let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
            friendDocRef.updateData([
                "Following": FieldValue.arrayUnion([self.uid])
            ])
            friendDocRef.updateData([
                "Friend Requests": FieldValue.arrayRemove([self.uid])
            ])
            
            // Add friend to other user's firestore
            let requestDocRef = db.collection("friends").document(self.uid)
            requestDocRef.updateData([
                "Followers": FieldValue.arrayUnion([Auth.auth().currentUser?.uid])
            ])
            requestDocRef.updateData([
                "Pending Friends": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
            ])
            
            alert.dismiss(animated: true) {
                SCLAlertView().showSuccess("You are now following \(self.name.text!)", subTitle: "You will have access to their shared data")
            }
            
        }
        
        alert.addButton("No") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showNotice("Are you sure you want to accept this request?", subTitle: "")
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Yes") {
            let db = Firestore.firestore()
            
            //  Remove friend from current user's pending friends
            let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
            friendDocRef.updateData([
                "Friend Requests": FieldValue.arrayRemove([self.uid])
            ])
            
            // Add request to other user's firestore
            let requestDocRef = db.collection("friends").document(self.uid)
            requestDocRef.updateData([
                "Pending Friends": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
            ])
        }
        
        alert.addButton("No") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showNotice("Are you sure you want to delete this request?", subTitle: "")
    }
}
