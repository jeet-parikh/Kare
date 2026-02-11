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

class BloodPressureCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        print("User ID: \(uid)")
        //        populateFields(userID: uid)
    }
    
    @IBOutlet weak var completedIndicatorImageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var optionsButton: UIButton!
    
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
    
    let db = Firestore.firestore()
    
    var dataDict : [String:[String]] = [:]
    
    fileprivate func removeCellIDFromInProgressArray() {
        
        let arrayIdentifier = (self.reuseIdentifier ?? "bloodPressureCell") + String(self.tag)
        
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
        
        if self.isUserInteractionEnabled == true {
            print(1)
            topTextField.placeholder = "Enter"
            bottomTextField.placeholder = "Enter"
        } else {
            print(2)
            topTextField.placeholder = "Empty"
            bottomTextField.placeholder = "Empty"
        }
        
        
        topTextField.text = ""
        bottomTextField.text = ""
        print("Populating BP Fields")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        print("DATE: \(formattedDate)")
        
        //        print(1)
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(userID).collection(self.reuseIdentifier ?? "nil").document(formattedDate)
        
        print("BP DOCREF PATH: \(docRef.path)")

        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                if let dataDescription = document.data()?["data"] as? [String:[String]] {
                    
                    self.topTextField.text = dataDescription[String(self.tag)]?[1]
                    self.bottomTextField.text = dataDescription[String(self.tag)]?[2]
                    
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "HH.mm"
                    
                    if let dateValue = dateFormatterGet.date(from: dataDescription[String(self.tag)]?[0] ?? dateFormatterGet.string(from: Date())) {
                        self.timePicker.setDate(dateValue, animated: true)
                    } else {
                        self.timePicker.setDate(Date(), animated: true)
                    }
                    
                    self.removeCellIDFromInProgressArray()
                    
                } else {
                    
                    self.removeCellIDFromInProgressArray()
                }
                
                if self.topTextField.text != "" && self.bottomTextField.text != "" {
                    // both selected
                    self.completedIndicatorImageView.isHidden = false
                    self.timeHeightConstraint.constant = self.bottomTextField.frame.height
                    
                } else if self.topTextField.text != "" || self.bottomTextField.text != "" {
                    // one selected
                    self.completedIndicatorImageView.isHidden = false
                    self.timeHeightConstraint.constant = self.bottomTextField.frame.height
                } else {
                    // both not filled
                    self.completedIndicatorImageView.isHidden = true
                    self.timeHeightConstraint.constant = 0
                    self.timePicker.setDate(Date(), animated: true)
                }
            } else {
                
                self.removeCellIDFromInProgressArray()
                
            }
        }
        
        if self.topTextField.text != "" && self.bottomTextField.text != "" {
            // both selected
            self.completedIndicatorImageView.isHidden = false
            self.timeHeightConstraint.constant = self.bottomTextField.frame.height
            
        } else if self.topTextField.text != "" || self.bottomTextField.text != "" {
            // one selected
            self.completedIndicatorImageView.isHidden = false
            self.timeHeightConstraint.constant = self.bottomTextField.frame.height
        } else {
            // both not filled
            self.completedIndicatorImageView.isHidden = true
            self.timeHeightConstraint.constant = 0
            self.timePicker.setDate(Date(), animated: true)
        }

    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        if topTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" || bottomTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            addData()
        } else {
            deleteData()
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        timePicker.setDate(Date(), animated: true)
        
        if topTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" || bottomTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            addData()
        } else {
            deleteData()
        }
        
    }
    
    func addData() {
        
        if topTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && bottomTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            completedIndicatorImageView.isHidden = false
        } else {
            completedIndicatorImageView.isHidden = true
        }
        
        timeHeightConstraint.constant = topTextField.frame.height
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: date)
        
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(uid).collection(self.reuseIdentifier!).document(formattedDate)
        
        let tag = self.tag
        
        let timeDate = timePicker.date
        formatter.dateFormat = "HH.mm"
        let formattedTime = formatter.string(from: timeDate)
        // tag will be zero for all single cells, it will increment on the multiple cells screen
        
        dataDict[String(tag)] = [formattedTime, topTextField.text ?? "", bottomTextField.text ?? ""]
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
        let dataRef = db.collection("data").document(uid).collection(self.reuseIdentifier!).document(formattedDate)
        
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
                            .collection(self.reuseIdentifier!)
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
                        
                        let docRef = db.collection("data").document(self.uid).collection(self.reuseIdentifier!).document(formattedDate)
                        
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
        print(self.reuseIdentifier)
        vc.postSegueID = self.reuseIdentifier!
        print(vc.postSegueID)
        parentContainerViewController()?.performSegue(withIdentifier: "segueToCustomizationViewEditButton", sender: parentContainerViewController())
    }
    
    
}
