//
//  ViewUserViewItemsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 5/8/21.
//
 
import UIKit
import FirebaseFirestore
import EmptyDataSet_Swift
//import FirebaseAuth

class ViewUserViewAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "This person has not added any items.",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "sadEmptyFolderImage"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
    }
    
    var identifierList: [String] = []
    var uid: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifierList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewAllTableViewCell") as! ViewAllTableViewCell
        
        cell.selectionStyle = .none
        
        let id = self.identifierList[indexPath.row]
        
        cell.collectionViewIdentifier = id
        
        let db = Firestore.firestore()
        let dataRef = db.collection("data").document(uid).collection(id)
        
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
    
}
