//
//  AddItemTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/16/21.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = view.frame.height / 6
        // Initialization code
    }
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var collectionViewIdentifier: String = ""
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
