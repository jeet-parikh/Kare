//
//  FriendsPopoverTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/21/21.
//

import UIKit

class FriendsPopoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    var uid: String = ""
    var firstName: String = ""
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        view.layer.cornerRadius = view.frame.height / 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
