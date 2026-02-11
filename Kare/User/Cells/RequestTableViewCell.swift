//
//  RequestTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/8/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SCLAlertView

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    
    var uid: String = ""
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Yes") {
            let db = Firestore.firestore()
            
            // Remove request to current user's pending friends
            let friendDocRef = db.collection("friends").document(Auth.auth().currentUser!.uid)
            friendDocRef.updateData([
                "Pending Friends": FieldValue.arrayRemove([self.uid])
            ])
            
            // Remove request to other user's firestore
            let requestDocRef = db.collection("friends").document(self.uid)
            requestDocRef.updateData([
                "Friend Requests": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
            ])
            
            if let vc = self.parentContainerViewController() as? FriendSearchViewController {
                vc.searchTableView.reloadData()
            }
            
        }
        
        alert.addButton("No") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showWarning("Are you sure you want to delete this request?", subTitle: "")
        
    }
    
    
}
