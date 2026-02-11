//
//  DefaultCollectionViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/20/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import NotificationBannerSwift

class ErrorCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if isEditable {
            contentView.isUserInteractionEnabled = true
            trashButton.isHidden = false
        } else {
            contentView.isUserInteractionEnabled = false
            trashButton.isHidden = true
        }
    }
    
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    
    
    var identifier: String = ""
    var isEditable: Bool = true
    @IBOutlet weak var trashButton: UIButton!
    
    @IBAction func trashPressed(_ sender: UIButton) {
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(Auth.auth().currentUser!.uid)
        
        docRef.updateData([
            "identifiers": FieldValue.arrayRemove([identifier]),
            identifier: FieldValue.delete()
        ])
        
        let frequencyRef = docRef.collection(identifier).document("frequency")
        frequencyRef.updateData([
            "general": FieldValue.delete(),
            "specific": FieldValue.delete()
        ])
        
        let vc = parentContainerViewController() as! HomeViewController
        vc.showSuccessfullyDeleted()
    }
}
