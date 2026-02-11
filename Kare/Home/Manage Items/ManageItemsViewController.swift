//
//  ManageItemsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/23/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import EmptyDataSet_Swift

class ManageItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "You have not added any items. Click the + to get started!",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "sadEmptyFolderImage"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    var identifierList: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifierList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageItemsTableViewCell") as! ManageItemsTableViewCell
        
        cell.selectionStyle = .none
        
        let id = self.identifierList[indexPath.row]
        
        cell.collectionViewIdentifier = id
        
        let db = Firestore.firestore()
        let dataRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(id)
        
        dataRef.document("info").getDocument { document, error in
            if error != nil {
                print("error retrieving \(id) document")
            } else {
                let dataDescription = document?.data()
                cell.title.text = dataDescription?["title"] as? String
                
                let catInfo = dataDescription?["categoryInfo"] as? [String]
                cell.iconImage.image = UIImage(systemName: (catInfo?[1])!)
                cell.iconImage.tintColor = UIColor(hexString: catInfo?[2])
                
            }
        }
        
        dataRef.document("frequency").getDocument { (document, error) in
            if error != nil {
                print("error retrieving \(id) document")
            } else {
                let frequency = document?.data()!["general"] as? String
                cell.frequency.text = frequency?.capitalized
                
                if frequency == "Monthly" {
                    cell.weekdayButtonsStackView.isHidden = true
                    cell.monthlyDescriptionLabel.isHidden = false
                    
                    var message = ""
                    let indexList = document?.data()!["specific"] as! [Int]
                    
                    var count = 0
                    for index in indexList {
                        if count == 0 {
                            message += String(index)
                            count += 1
                        } else {
                            message += ", \(index)"
                        }
                    }
                    
                    cell.monthlyDescriptionLabel.text = message
                    
                } else {
                    
                    cell.weekdayButtonsStackView.isHidden = false
                    cell.monthlyDescriptionLabel.isHidden = true
                    
                    for button in cell.weekdayButtons {
                        button.layer.cornerRadius = button.frame.height / 2
                        button.backgroundColor = .systemBackground
                        button.setTitleColor(Constants.Theme.themeColor, for: .normal)
                    }
                    
                    let indexList = document?.data()!["specific"] as! [Int]
                    for index in indexList {
                        for button in cell.weekdayButtons {
                            if button.tag == index {
                                button.backgroundColor = Constants.Theme.themeColor
                                button.setTitleColor(.white, for: .normal)
                            }
                        }
                    }
                }
            }
        }
        
        return cell
        
    }
    
    var identifier: String = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCustomizationViewManageItems" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! CustomizationViewController
            
            let db = Firestore.firestore()
            let docRef = db.collection("data")
                .document(Auth.auth().currentUser!.uid)
                .collection(identifier)
                .document("info")
            
            docRef.getDocument { (document, error) in
                if error != nil {
                    print("error finding cell descriptions")
                } else {
                    vc.titleTextField?.text = document?.data()?["title"] as? String
                    vc.unitsTextField?.text = document?.data()?["units"] as? String
                }
            }
            
            vc.collectionViewIdentifier = identifier
            vc.adding = false
            
            if self.identifier.prefix(6) == "Custom" {
                vc.custom = true
            } else {
                vc.custom = false
            }
        } else if segue.identifier == "viewAllAddItemSegue" {
            let vc = segue.destination as! AddCellViewController
            
            let db = Firestore.firestore()
            let docRef = db.collection("data").document("Cell Descriptions")
            
            docRef.getDocument { (document, error) in
                
                if error != nil {
                    print("error finding cell descriptions")
                    vc.itemCount = 0
                } else {
                    let data = document?.data()!["identifiers"] as! [String]
                    vc.itemCount = data.count + 1
                }
            }
            
            let userDocRef = db.collection("data").document(Auth.auth().currentUser!.uid)
            
            userDocRef.getDocument { (document, error) in
                
                if error != nil {
                    print("error finding cell descriptions")
                } else {
                    guard let data = document?.data()?["identifiers"] as? [String] else {return}
                    vc.identifierList = data
                }
            }
        }
    }
    
}
