//
//  AddCellViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/16/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SCLAlertView

class AddCellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(identifierList)
    }
    
    var itemCount = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemCount)
        return itemCount
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell") as! AddItemTableViewCell
        
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            
            cell.titleLabel.text = "Custom Item"
            //            cell.descriptionLabel.text = "Add an item with a custom name and units"
            cell.iconImageView.image = UIImage(systemName: "plus")
            cell.iconImageView.tintColor = .flatGreenColorDark()
            cell.collectionViewIdentifier = "customCell"
            
        } else {
            print("CHECKPOINT 1")
            let docRef = db.collection("data")
                .document("Cell Descriptions")
            print("CHECKPOINT 2")
            docRef.getDocument { (idDocument, idError) in
                if idError != nil {
                    print("error getting cell ids")
                } else {
                    let data = idDocument?.data()!["identifiers"] as! [String]
                    print(data)
                    let identifier = data[indexPath.row - 1]
                    
                    docRef.collection("information")
                        .document(identifier)
                        .getDocument { infoDocument, infoError in
                            if infoError != nil {
                                print("Error getting cell information (title, description, image)")
                            } else {
                                let content = infoDocument?.data()
                                cell.titleLabel.text = content?["Title"] as? String
                                // cell.descriptionLabel.text = content["Description"]
                                cell.iconImageView.image = UIImage(systemName: content?["Icon Name"] as! String)
                                cell.collectionViewIdentifier = identifier
                                if let cat = content?["categoryInfo"] as? [String] {
                                    cell.iconImageView.tintColor = UIColor(hexString: cat[2])
                                }
//                                cell.iconImageView.tintColor = UIColor(hexString: content?["categoryInfo"][2])
//                                cell.collectionViewIdentifier = content?["id"] as! String
                            }
                        }
                }
            }
        }
        
        return cell
        
    }
    
    var selectedIdentifier: String = ""
    
    var identifierList: [String] = []
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AddItemTableViewCell
        print(identifierList)
        print(cell.collectionViewIdentifier)
        var id =  cell.collectionViewIdentifier
//        if cell.collectionViewIdentifier != "CustomYNMedicine" {
//            id = cell.collectionViewIdentifier
//        }
        
        if identifierList.contains(id) {
            SCLAlertView().showError("You cannot add this item", subTitle: "Item already exists!")
        } else {
            selectedIdentifier = id
            performSegue(withIdentifier: "segueToCustomizationView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCustomizationView" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! CustomizationViewController
            
            print(selectedIdentifier)
            
            vc.adding = true
            
            if selectedIdentifier == "customCell" || selectedIdentifier == "CustomYNMedicine" {
                vc.custom = true
            } else {
                vc.custom = false
            }
            
            if selectedIdentifier == "CustomYNMedicine" {
                vc.collectionViewIdentifier = "customCell"
            } else {
                vc.collectionViewIdentifier = selectedIdentifier
            }
            
            let db = Firestore.firestore()
            let docRef = db.collection("data").document("Cell Descriptions").collection("information").document(self.selectedIdentifier)
            
            docRef.getDocument { (document, error) in
                if error != nil {
                    print("error finding cell descriptions")
                } else {
                    
                    if self.selectedIdentifier == "CustomYNMedicine" {
                        vc.titleTextField.placeholder = "Enter Medicine Name"
                    } else {
                        vc.titleTextField.placeholder = "Enter Title"
                    }
                    
                    let content = document?.data()
                    vc.titleTextField.text = content?["Title"] as? String
                    vc.unitsTextField.text = content?["units"] as? String
                    
                    if vc.titleTextField.text == "Medicine" {
                        vc.titleTextField.text = ""
                    }
                    
                    print(content?["categoryInfo"] as? [String])
                    vc.selectedCategoryInfoArray = content?["categoryInfo"] as? [String] ?? ["Click to select", "hand.tap.fill", "#6B85FF"]

                    print(content)
                    
                    
                }
            }
            
            
            
        }
    }
}
