//
//  Functions.swift
//  Kare
//
//  Created by Jeet Parikh on 8/15/21.
//

import UIKit
import FirebaseFirestore
import SCLAlertView

struct Functions {
    
    struct CollectionView {
        
        static func getNonMultiCollectionViewCell(
            identifier: String,
            indexPath: IndexPath,
            collectionView: UICollectionView,
            uid: String,
            widthConstraint: CGFloat,
            date: Date = Date(),
            optionsButtonHidden: Bool = false,
            isEditable: Bool = true,
            time: Date? = nil
        ) -> UICollectionViewCell {
            
            // Check if Custom
            switch identifier.prefix(8) {
            case "CustomSF":
                let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customSFCell", for: indexPath) as! CustomSingleFieldCollectionViewCell
                
                returnCell.isUserInteractionEnabled = isEditable
                
                returnCell.cellID = identifier
                
                returnCell.uid = uid
                returnCell.date = date
                returnCell.optionsButton.isHidden = optionsButtonHidden
                
                returnCell.cellWidthConstraint.constant = widthConstraint
                returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
                
                if let setTime = time {
                    returnCell.timePicker.setDate(setTime, animated: true)
                }
                
                self.styleCell(returnCell)
                
                
                return returnCell
                
            case "CustomYN":
                let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customYNCell", for: indexPath) as! CustomYesNoCollectionViewCell
                
                returnCell.isUserInteractionEnabled = isEditable

                returnCell.cellID = identifier
                
                returnCell.uid = uid
                returnCell.date = date
                returnCell.optionsButton.isHidden = optionsButtonHidden
                
                returnCell.cellWidthConstraint.constant = widthConstraint
                returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
                
                if let setTime = time {
                    returnCell.timePicker.setDate(setTime, animated: true)
                }
                
                self.styleCell(returnCell)
                
                
                return returnCell
                
            case "CustomTE":
                let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customTECell", for: indexPath) as! CustomTextEntryCollectionViewCell
                
                returnCell.isUserInteractionEnabled = isEditable

                returnCell.cellID = identifier
                
                returnCell.uid = uid
                returnCell.date = date
                returnCell.optionsButton.isHidden = optionsButtonHidden
                
                returnCell.cellWidthConstraint.constant = widthConstraint
                returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
                
                if let setTime = time {
                    returnCell.timePicker.setDate(setTime, animated: true)
                }
                
                self.styleCell(returnCell)
                
                return returnCell
                
            default:
                print("Not a Custom Cell")
            }
            
            // Premade cells
            switch identifier {
            case "bloodPressureCell":
                let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bloodPressureCell", for: indexPath) as! BloodPressureCollectionViewCell
                
                returnCell.isUserInteractionEnabled = isEditable

                returnCell.uid = uid
                returnCell.date = date
                returnCell.optionsButton.isHidden = optionsButtonHidden
                
                returnCell.cellWidthConstraint.constant = widthConstraint
                returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
                
                if let setTime = time {
                    returnCell.timePicker.setDate(setTime, animated: true)
                }
                
                self.styleCell(returnCell)
                
                
                return returnCell
                
            default:
                let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "errorCell", for: indexPath) as! ErrorCollectionViewCell
                
                returnCell.isUserInteractionEnabled = isEditable
                
                returnCell.identifier = identifier
                
                returnCell.cellWidthConstraint.constant = widthConstraint
                returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
                
                self.styleCell(returnCell)
                

                return returnCell
            }
        }
        
        static func getMultiCollectionViewCell(
            identifier: String,
            indexPath: IndexPath,
            collectionView: UICollectionView,
            uid: String,
            widthConstraint: CGFloat,
            numPerDay: Int,
            date: Date = Date(),
            optionsButtonHidden: Bool = false,
            isEditable: Bool = true,
            isViewOnlyMode: Bool = false
        ) -> UICollectionViewCell {
            
            let returnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiCell", for: indexPath) as! MultiCollectionViewCell

            returnCell.screen2CellID = identifier
            returnCell.uid = uid
            
            returnCell.numPerDay = numPerDay
            returnCell.viewOnlyMode = isViewOnlyMode
            
            returnCell.date = date
            
            // end of cell features, start of cell UI design
            
            returnCell.optionsButton.isHidden = optionsButtonHidden
            
            returnCell.cellWidthConstraint.constant = widthConstraint
            returnCell.cellHeightConstraint.constant = widthConstraint * 1.4
            
            self.styleCell(returnCell)
            
            returnCell.isUserInteractionEnabled = isEditable

            return returnCell
        }
        
        
        static func styleCell(_ cell: UICollectionViewCell) {
            cell.layer.cornerRadius = cell.frame.height / 10
            cell.backgroundColor = .systemGray5
            
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowRadius = 3
            cell.layer.masksToBounds = false
            cell.clipsToBounds = false
        }
        
        
        static func registerCells(collectionView: UICollectionView) {
            // Premade
            collectionView.register(UINib.init(nibName: "BloodPressureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bloodPressureCell")
            collectionView.register(UINib.init(nibName: "ErrorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "errorCell")
            // Custom
            collectionView.register(UINib.init(nibName: "CustomSingleFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customSFCell")
            collectionView.register(UINib.init(nibName: "CustomYesNoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customYNCell")
            collectionView.register(UINib.init(nibName: "CustomTextEntryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customTECell")
            collectionView.register(UINib.init(nibName: "MultiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "multiCell")
        }
    }
    
    struct Trends {
        
        static let db = Firestore.firestore()
        static var dataArray: [[String]] = []
        static var finished = false
        
        static func getData(
            identifier: String,
//            index: Int,
            uid: String,
            tableView: UITableView
        )
//        -> [[String]]
        {
            
//            var dataArray: [[String]] = []
            finished = false
            
            let docRef = db.collection("data")
                .document(uid)
                .collection(identifier)
    //        print(6)
            docRef.order(by: FieldPath.documentID()).getDocuments { querySnapshot, error in
                if error != nil {
                    SCLAlertView().showError("Error", subTitle: "Error retrieving data")
                    finished = true
                } else {
    //                print(7)
                    
                    if let dataDescription = querySnapshot?.documents {
                        for document in dataDescription {
                            if document.documentID == "frequency" || document.documentID == "info" {
                                continue
                            }
    //                        print(8)
                            let date = document.documentID
    
                            let dateFormatterGet = DateFormatter()
                            dateFormatterGet.dateFormat = "yyyy.MM.dd"
    
                            let dateValue = dateFormatterGet.date(from: date)
    
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM d, yyyy"
                            let formattedDate = dateFormatter.string(from: dateValue!)
    
                            var string = ""
                            var iteration = 0
    
                            print("Document Data: \(document.data())")
    //                        print(9)
                            let data = document.data()
                            let sortedKeys = data.keys.sorted()
                            for key in sortedKeys {
    //                            print(10)
                                if iteration == 0 {
    //                                print(12)
                                    string += data[key] as! String
                                    iteration += 1
                                } else {
    //                                print(13)
                                    string += " | \(data[key] as! String)"
                                    iteration += 1
                                }
                            }
    //                        print(14)
                            dataArray.insert([formattedDate,string], at: 0)
    //                        print(15)
//                            tableView.reloadData()
                        }
                        finished = true
//                        tableView.reloadData()
                    }
                }
            }
//            return dataArray

        }
        
        
        
    }
    
}
