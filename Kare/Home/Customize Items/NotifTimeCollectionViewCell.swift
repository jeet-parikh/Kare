//
//  NotifTimeCollectionViewCell.swift
//  ProKare
//
//  Created by Jeet Parikh on 1/10/22.
//

import UIKit

class NotifTimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var notifTimePicker: UIDatePicker!
    
//    var hour: Int = 17
//    var min: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setTime(hour: Int, min: Int) {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = min
        notifTimePicker.setDate(calendar.date(from: components)!, animated: true)
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: self.notifTimePicker.date)
        let compHour = components.hour!
        let compMin = components.minute!
        
        let parentVC = self.parentContainerViewController() as! CustomizationViewController
        parentVC.notifTimeArray[self.tag] = [compHour,compMin]
        
        print("VALUE CHANGED")
        print(parentVC.notifTimeArray)
        
    }
    
    
}
