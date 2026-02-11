//
//  BloodPressureCollectionViewCell.swift
//  Kare
//
//  Created by Jeet Parikh on 4/14/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SCLAlertView
import SkeletonView

class CustomSingleFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataTextField.delegate = self
        dataTextField.isEnabled = true
        dataTextField.text = "test"
        
        print("\n\n\n\n\n\n single field cell")
        print(cellID)
        print(tag)
        print(parentContainerViewController())
        
//        self.showAnimatedSkeleton()
//        backgroundColor = .white
//        self.isUserInteractionEnabled = false
        
        print("User ID: \(uid)")
        
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var completedIndicatorImageView: UIImageView!
    @IBOutlet weak var dataTextField: UITextField!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePicker: UIDatePicker!
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
            
            print("\n\n\n\n\n\n single field cell")
            print(cellID)
            print(tag)
            print(parentContainerViewController())
            
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
    
    fileprivate func removeCellIDFromInProgressArray() {
        
        print("remove function called")
        print(self.parentContainerViewController())
        
        let arrayIdentifier = self.cellID + String(self.tag)
        
        if self.parentContainerViewController() as? HomeViewController != nil {
            
            // parent view is HomeViewController
            
            let vc = self.parentContainerViewController() as! HomeViewController
            if let index = vc.cellsInProgress.firstIndex(of: arrayIdentifier) {
                print("index", index)
                vc.cellsInProgress.remove(at: index)
            }
            
        } else if self.parentContainerViewController() as? MultiCellViewController != nil {
            
            // parent view is MuliCellviewController
            
            print("\n\n\n ON MULTI SCREEN VC CONTAINERVC")
            
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
    
    //MARK: - Populate Fields
    
    func populateFields(userID: String) {
        
        if self.isUserInteractionEnabled == true {
            dataTextField.placeholder = "Enter"
        } else {
            dataTextField.placeholder = "Empty"
        }
        
        
        dataTextField.text = ""
        print("Populating Fields")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date ?? Date(timeIntervalSince1970: 5))
        
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
                    
//                    let randomInt = Int.random(in: 1..<3)
//                    if randomInt == 1 {
//
//                    }
                    self.removeCellIDFromInProgressArray()
                    
//                    self.hideSkeleton()
//                    self.isUserInteractionEnabled = true
//                    self.hideSkeleton()
                    //                    print(7)
                }
            }
        }
        
        //        print(2)
        docRef.document(formattedDate).getDocument { (document, error) in
            //            print(3)
            if let document = document, document.exists {
                //                print(4)
                if let dataDescription = document.data()?["data"] as? [String:[String]] {
                    print(dataDescription)
                    //                    print(5)
                    self.dataTextField.text = dataDescription[String(self.tag)]?[1]
                    
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "HH.mm"
                    
                    
                    if let dateValue = dateFormatterGet.date(from: dataDescription[String(self.tag)]?[0] ?? dateFormatterGet.string(from: Date())) {
                        self.timePicker.setDate(dateValue, animated: true)
                    } else {
                        self.timePicker.setDate(Date(), animated: true)
                    }
                    
                }
                
                if self.dataTextField.text != "" {
                    self.completedIndicatorImageView.isHidden = false
                    self.timeHeightConstraint.constant = self.dataTextField.frame.height
                    //                    NSLayoutConstraint.deactivate([self.timePicker.heightAnchor.constraint(equalToConstant: 0)])
                } else {
                    self.completedIndicatorImageView.isHidden = true
                    self.timeHeightConstraint.constant = 0
                    //                    NSLayoutConstraint.activate([self.timePicker.heightAnchor.constraint(equalToConstant: 0)])
                }
            }
        }
        
        if self.dataTextField.text != "" {
            self.completedIndicatorImageView.isHidden = false
            self.timeHeightConstraint.constant = self.dataTextField.frame.height
            //            NSLayoutConstraint.deactivate([self.timePicker.heightAnchor.constraint(equalToConstant: 0)])
        } else {
            self.completedIndicatorImageView.isHidden = true
            self.timeHeightConstraint.constant = 0
            //            NSLayoutConstraint.activate([self.timePicker.heightAnchor.constraint(equalToConstant: 0)])
        }
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        if dataTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            addData(dataTextField.text!)
        } else {
            deleteData()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if dataTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            addData(dataTextField.text!)
        } else {
            deleteData()
        }
        
    }
    
    func addData(_ data: String) {
        
        timeHeightConstraint.constant = dataTextField.frame.height
        completedIndicatorImageView.isHidden = false
        
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
    
    func deleteData() {
        
        dataDict.removeValue(forKey: String(self.tag))
        print(dataDict)
        
        print("DELETE SF CALLED")
        
        timePicker.setDate(Date(), animated: true)
        timeHeightConstraint.constant = 0
        completedIndicatorImageView.isHidden = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        let db = Firestore.firestore()
        let dataRef = db.collection("data").document(uid).collection(cellID).document(formattedDate)
        
        dataRef.getDocument { document , error  in
            if error != nil {
                print(error, error?.localizedDescription)
            } else {
                
                if let safeDocument = document?.data() {
                    var data = safeDocument["data"] as! [String:[String]]
                    
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
    }
    
    
    @IBAction func optionsButtonPressed(_ sender: UIButton) {
        
        let vc = parentContainerViewController() as! HomeViewController
        print(cellID)
        vc.postSegueID = cellID
        print(vc.postSegueID)
        parentContainerViewController()?.performSegue(withIdentifier: "segueToCustomizationViewEditButton", sender: parentContainerViewController())
    }
    
    
}
