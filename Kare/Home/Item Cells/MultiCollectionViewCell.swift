//
//  MultiCollectionViewCell.swift
//  ProKare
//
//  Created by Jeet Parikh on 1/17/22.
//

import UIKit
import FirebaseFirestore
import SCLAlertView

class MultiCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("\n\ndid awake from nib\n\n")
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
//    @IBOutlet weak var completedIndicator: UIImageView!
    @IBOutlet weak var fractionCompletionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewOnlyMode: Bool = false
    var screen2CellID : String = "filler"
    
    fileprivate func removeCellIDFromInProgressArray() {
        
        let arrayIdentifier = self.screen2CellID + String(self.tag)
        
        if self.parentContainerViewController() as? HomeViewController != nil {
            
            // parent view is HomeViewController
            
            let vc = self.parentContainerViewController() as! HomeViewController
            if let index = vc.cellsInProgress.firstIndex(of: arrayIdentifier) {
                print("index", index)
                vc.cellsInProgress.remove(at: index)
            }
            
        } else if self.parentContainerViewController() as? MultiCellViewController != nil {
            
            // parent view is MuliCellviewController
            
            let vc = self.parentContainerViewController() as! MultiCellViewController
            if let index = vc.cellsInProgress.firstIndex(of: arrayIdentifier) {
                print("index", index)
                vc.cellsInProgress.remove(at: index)
            }
        } else if self.parentContainerViewController() as? UITabBarController != nil {
            
            // parent view is ViewUserItemsViewController
            
            let tab = parentContainerViewController() as! UITabBarController
            let vc = tab.viewControllers?[0] as! ViewUserItemsViewController
            
            if let index = vc.cellsInProgress.firstIndex(of: arrayIdentifier) {
                print("index", index)
                vc.cellsInProgress.remove(at: index)
            }
        }
    }
    
    var date : Date = Date() {
        didSet {
            // this code loads in title to be shown in the title label
            // it is in the didSet of "date" because this is set after the cell ID and uid, so the following code will execute properly
            let db = Firestore.firestore()
            let docRef = db.collection("data").document(uid).collection(screen2CellID)
            
            docRef.document("info").getDocument { document, error in
                if error != nil {
                    print("ERROR: RETRIEVING CELL INFO")
                    
                    self.removeCellIDFromInProgressArray()
                    
                } else {
                    if let dataDescription = document?.data() {
                        //                    print(5)
                        self.titleLabel.text = dataDescription["title"] as! String
                        
                        let catInfo = dataDescription["categoryInfo"] as? [String]
                        self.iconImageView.image = UIImage(systemName: (catInfo?[1])!)
                        self.iconImageView.tintColor = UIColor(hexString: catInfo?[2])
                        
                        self.removeCellIDFromInProgressArray()
                        //                    print(7)
                    }
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let formattedDate = formatter.string(from: date)
            
            self.fractionCompletionLabel.text = "0/" + String(self.numPerDay)
            
            docRef.document(formattedDate).getDocument { document , error  in
                if error != nil {
                    print(error, error?.localizedDescription)
                    
                } else {
                    if let dataDescription = document?.data()?["data"] as? [String:[String]] {
                        
                        print(self.screen2CellID)
                        print("dataDescription.count: ", dataDescription.count)
                        print("total: ", self.numPerDay)
                        
                        self.fractionCompletionLabel.text = String(dataDescription.count) + "/" + String(self.numPerDay)
                        
//                        if dataDescription.count == self.numPerDay {
//                            self.completedIndicator.isHidden = false
//                        } else {
//                            self.completedIndicator.isHidden = true
//                        }
                    }
                }
            }
            
            // if view only mode is true, change the button text to "view data" and make the next screen un-editable
            if viewOnlyMode {
                recordButton.setTitle("View Data", for: .normal)
            } else {
                recordButton.setTitle("Click to Record Data", for: .normal)
            }
                    
            
        }
    }
    
    var uid : String = "filler"
    
    var numPerDay : Int = 1
    
    @IBAction func optionsButtonPressed(_ sender: UIButton) {
        let vc = parentContainerViewController() as! HomeViewController
        
        vc.postSegueID = screen2CellID
        
        parentContainerViewController()?.performSegue(withIdentifier: "segueToCustomizationViewEditButton", sender: parentContainerViewController())
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if parentContainerViewController() is HomeViewController {
            
            let vc = parentContainerViewController() as! HomeViewController
            
            vc.postSegueID = screen2CellID
            vc.postSegueDate = date
            vc.postSegueNumPerDay = numPerDay
            vc.postSegueTitle = titleLabel.text ?? "Today"
            print(numPerDay)
            
            parentContainerViewController()?.performSegue(withIdentifier: "segueToMultiVC", sender: parentContainerViewController())
            
        } else if parentContainerViewController() is UITabBarController {
            
            let tab = parentContainerViewController() as! UITabBarController
            let vc = tab.viewControllers?[0] as! ViewUserItemsViewController
            
            vc.postSegueID = screen2CellID
            vc.postSegueDate = date
            vc.postSegueNumPerDay = numPerDay
            vc.postSegueTitle = titleLabel.text ?? "Today"
            print(numPerDay)

            vc.performSegue(withIdentifier: "segueToMultiFromTabControl", sender: vc)
            
        }
        
        
    }
    
    
}
