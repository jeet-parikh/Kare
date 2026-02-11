//
//  ViewAllTableViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 5/8/21.
//

import UIKit

class ViewAllTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = view.frame.height / 6
        
    }
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var frequency: UILabel!
    var collectionViewIdentifier: String = ""
    @IBOutlet weak var view: UIView!
    
    //Days of week buttons
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    
    @IBOutlet var weekdayButtons: [UIButton]!
    @IBOutlet weak var weekdayButtonsStackView: UIStackView!
    @IBOutlet weak var monthlyDescriptionLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
