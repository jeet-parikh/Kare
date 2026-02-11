//
//  CustomYesNoCollectionViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 8/19/21.
//

import UIKit
import FirebaseFirestore
import SCLAlertView

class CustomYesNoCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.backgroundColor = .systemBackground
        checkButton.tintColor = .systemGray
        checkButton.layer.cornerRadius = checkButton.frame.height / 3
        
        xmarkButton.backgroundColor = .systemBackground
        xmarkButton.tintColor = .systemGray
        xmarkButton.layer.cornerRadius = xmarkButton.frame.height / 3
        
        print("User ID: \(uid)")
        //        populateFields(userID: uid)
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var xmarkButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePicker: UIDatePicker!
//    @IBOutlet weak var timeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeHeightConstraint: NSLayoutConstraint!
    
    var uid: String = "filler" {
        didSet {
            print("SET UID to: \(uid)")
            //            populateFields(userID: uid)
        }
    }
    
    var date: Date = Date() {
        didSet {
            print("SET DATE to: \(date)")
            populateFields(userID: uid)
        }
    }
    
    var cellID: String = "" {
        didSet {
            print("SET cell id TO \(cellID)")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            let formattedDate = formatter.string(from: date)
            
            let docRef = db.collection("data").document(uid).collection(cellID).document(formattedDate)
            
            docRef.getDocument { document, error in
                if error != nil {
                    print(error)
                    print(error?.localizedDescription)
                } else {
                    if let data = document?.data() as? [String:[String]] {
                        self.dataDict = data
                    } else {
                        self.dataDict = [:]
                    }
                }
            }
        }
    }
    
    let db = Firestore.firestore()
    
    var dataDict : [String:[String]] = [:]
    
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        
        deSelectNo()
        
        timePicker.setDate(Date(), animated: true)
        
        if checkButton.backgroundColor == .systemBackground {
            // Selected
            
            selectYes()
            
            addData("Yes")
            
        } else {
            // Unselected
            
            deSelectYes()
            
            deleteData()
            
        }
        
    }
    
    func selectYes() {
        checkButton.backgroundColor = .flatGreen().withAlphaComponent(0.3)
        checkButton.tintColor = .flatGreen()
    }
    
    func deSelectYes() {
        checkButton.tintColor = .systemGray
        checkButton.backgroundColor = .systemBackground
//        if traitCollection.userInterfaceStyle == .light {
//            checkButton.backgroundColor = .flatWhite()
//            checkButton.tintColor = .systemGray
//        } else {
//            checkButton.backgroundColor = .flatGrayColorDark()
//            checkButton.tintColor = .systemGray
//        }
    }
    
    func selectNo() {
        xmarkButton.backgroundColor = .flatRed().withAlphaComponent(0.3)
        xmarkButton.tintColor = .flatRed()
    }
    
    func deSelectNo() {
        xmarkButton.tintColor = .systemGray
        xmarkButton.backgroundColor = .systemBackground
//        if traitCollection.userInterfaceStyle == .light {
//            checkButton.backgroundColor = .flatWhite()
//            checkButton.tintColor = .systemGray
//        } else {
//            checkButton.backgroundColor = .flatGrayColorDark()
//            checkButton.tintColor = .systemGray
//        }
    }
    
    @IBAction func xmarkButtonPressed(_ sender: UIButton) {
        
        deSelectYes()
        
        timePicker.setDate(Date(), animated: true)
        
        if xmarkButton.backgroundColor == .systemBackground {
            // Selected
            
            selectNo()
            
            addData("No")
            
        } else {
            // Unselected
            
            deSelectNo()
            
            deleteData()
        }
        
    }
    
    func addData(_ data: String) {
        
        timeHeightConstraint.constant = checkButton.frame.height/2
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(uid).collection(cellID).document(formattedDate)
        
        let tag = self.tag
        
        let timeDate = timePicker.date
        formatter.dateFormat = "HH.mm"
        let formattedTime = formatter.string(from: timeDate)
        // tag will be zero for all single cells, it will increment on the multiple cells screen
        
        dataDict[String(tag)] = [formattedTime, data]
        print("Add data datadict: \(dataDict)")
        
        docRef.setData(["data": dataDict], merge: true) { (error) in
            if error != nil {
                // show error message
                SCLAlertView().showError("User data could not be saved", subTitle: "")
            }
        }
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        if checkButton.backgroundColor == .systemBackground && xmarkButton.backgroundColor == .systemBackground {
            // both unselected
            
        } else if checkButton.backgroundColor == .systemBackground {
            // check button not selected, so xmark button selected
            addData("No")
        } else {
            addData("Yes")
        }
    }
    
    
    func deleteData() {
        
        dataDict.removeValue(forKey: String(self.tag))
        print(dataDict)
        
        print("DELETE Y/N CALLED")
        
        timePicker.setDate(Date(), animated: true)
        timeHeightConstraint.constant = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        let db = Firestore.firestore()
        let dataRef = db.collection("data").document(uid).collection(cellID).document(formattedDate)
        
        dataRef.getDocument { document , error  in
            if error != nil {
                print(error, error?.localizedDescription)
            } else {
                var data = document?.data()?["data"] as! [String:[String]]
                if data.count == 1 || data.count == 0 {
                    // one item left, just got unselected, so now there is zero. Delete the entire document.
                    // data.count == 0 should never happen, but this is just in case
                    
                    db.collection("data")
                        .document(self.uid)
                        .collection(self.cellID)
                        .document(formattedDate)
                        .delete(completion: {error in
                            if let error = error {
                                print("ERROR DELETING DOCUMENT WHEN CELL CONTENTS EMPTY:")
                                print(error)
                            } else {
                                print("SUCCESSFULLY DELETED DOCUMENT WHEN CELL CONTENTS EMPTY")
                            }
                        })
                } else {
                    // there is still some data, in at least one of the multi cells
                    
                    data.removeValue(forKey: String(self.tag))
                    
                    let docRef = db.collection("data").document(self.uid).collection(self.cellID).document(formattedDate)
                    
                    docRef.setData(["data": data], merge: false) { (error) in
                        if error != nil {
                            // show error message
                            SCLAlertView().showError("User data could not be saved", subTitle: "")
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func removeCellIDFromInProgressArray() {
        
        let arrayIdentifier = self.cellID + String(self.tag)
        print(self.parentContainerViewController())
        
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
    
    
    func populateFields(userID: String) {
        
        // Deselet Both
        deSelectNo()
        deSelectYes()
        timeHeightConstraint.constant = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        print(formattedDate)
        
        //        print(1)
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(userID).collection(cellID)
        
        docRef.document("info").getDocument { document, error in
            if error != nil {
                print("ERROR: RETRIEVING CELL INFO")
                
                self.removeCellIDFromInProgressArray()
                
            } else {
                if let dataDescription = document?.data() {
                    //                    print(5)
                    self.titleLabel.text = dataDescription["title"] as! String
                    self.unitsLabel.text = dataDescription["units"] as! String
                    
                    let catInfo = dataDescription["categoryInfo"] as? [String]
                    self.iconImageView.image = UIImage(systemName: (catInfo?[1])!)
                    self.iconImageView.tintColor = UIColor(hexString: catInfo?[2])
                    
                    self.removeCellIDFromInProgressArray()
                }
            }
        }
        
        //        print(2)
        docRef.document(formattedDate).getDocument { (document, error) in
            //            print(3)
            if let document = document, document.exists {
                //                print(4)
                if let dataDescription = document.data()?["data"] as? [String:[String]] {
                    print("DATA DESCRIPTION: \(dataDescription)")
                    //                    print(5)
                    let value = dataDescription[String(self.tag)]?[1]
                    if value == "Yes" {
                        print("YES RETRIEVED")
                        self.selectYes()
                        self.deSelectNo()
                        self.timeHeightConstraint.constant = self.checkButton.frame.height/2
                    } else if value == "No" {
                        print("NO RETRIEVED")
                        self.selectNo()
                        self.deSelectYes()
                        self.timeHeightConstraint.constant = self.checkButton.frame.height/2
                    }
                    
                    
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "HH.mm"
                    
                    if let dateValue = dateFormatterGet.date(from: dataDescription[String(self.tag)]?[0] ?? dateFormatterGet.string(from: Date())) {
                        self.timePicker.setDate(dateValue, animated: true)
                    } else {
                        self.timePicker.setDate(Date(), animated: true)
                    }
                    
                    
                    //                    print(7)
                }
            }
        }
    }
    
    @IBAction func optionsButtonPressed(_ sender: UIButton) {
        
        let vc = parentContainerViewController() as! HomeViewController
        print(cellID)
        vc.postSegueID = cellID
        print(vc.postSegueID)
        parentContainerViewController()?.performSegue(withIdentifier: "segueToCustomizationViewEditButton", sender: parentContainerViewController())
    }
    
}
