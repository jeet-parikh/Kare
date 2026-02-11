//
//  ViewUserItemsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 5/3/21.
//

import UIKit
import FirebaseFirestore
//import FirebaseAuth
import SCLAlertView
import EmptyDataSet_Swift

class ViewUserItemsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var itemCount = 0
    
    var identifierList: [[String]] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var uid: String = ""
    
    var unFilteredIdentifierList: [String] = []
    
    var cellArray: [UICollectionViewCell] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(uid)
        
        collectionView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "This person has no items for today.",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "sadEmptyFolderImage"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        cellsLoadingView.isHidden = false
        cellsLoadingSpinner.startAnimating()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = dateFormatter.string(from: Date())
        navItem.title = date
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constants.Theme.themeColor
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navBar.standardAppearance =  appearance
        navBar.scrollEdgeAppearance = navBar.standardAppearance
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = Constants.Theme.themeColor
        navAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: 25),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navItem.standardAppearance = navAppearance
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //        print(2)
        Functions.CollectionView.registerCells(collectionView: collectionView)
        //        print(3)
        
//        let db = Firestore.firestore()
//
//        DispatchQueue.main.async {
//            let viewUserListener = db.collection("data").document(self.uid).addSnapshotListener { (document, error) in
//                //                print(4)
//                if let error = error {
//                    //                    print(5)
//                    self.cellsLoadingView.isHidden = false
//                    self.cellsLoadingSpinner.startAnimating()
//
//                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
//                    print("Error: \(error)")
//                } else {
//                    //                    print(6)
//                    self.itemCount = 0
//
//                    if let dataDescription = document?.data()?["identifiers"] as? [String] {
//                        self.unFilteredIdentifierList = dataDescription
//
//                        self.filterCellsUsingDates(dataDescription)
//
//                        //                        print(10)
//                        self.collectionView.reloadData()
//                        //                        print(11)
//                    } else {
//                        self.cellsLoadingView.isHidden = false
//                        self.cellsLoadingSpinner.startAnimating()
//                    }
//                }
//            }
//            Constants.allSnapshotListeners.append(viewUserListener)
//        }
//        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cellsLoadingSpinner.startAnimating()
        cellsLoadingView.isHidden = false
        firstScrollComplete = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        
        db.collection("data").document(self.uid).getDocument { (document, error) in
            //                print(4)
            if let error = error {
                //                    print(5)
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                print("Error: \(error)")
            } else {
                //                    print(6)
                self.itemCount = 0
                
                if let dataDescription = document?.data()?["identifiers"] as? [String] {
                    self.unFilteredIdentifierList = dataDescription
                    
                    self.filterCellsUsingDates(dataDescription)
                    
                    //                        print(10)
                    self.collectionView.reloadData()
                    //                        print(11)
                } else {
                    self.cellsLoadingView.isHidden = true
                    self.cellsLoadingSpinner.stopAnimating()
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func viewAllPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    //MARK: - Collection View
    
    @IBOutlet weak var cellsLoadingView: UIView!
    @IBOutlet weak var cellsLoadingSpinner: UIActivityIndicatorView!
    var firstScrollComplete: Bool = false
    var cellsInProgress: [String] = [] {
       didSet {
           print("\n\n\n\n\n\n ViEW USER -- IN PROGRESS UPDATED:")
           print(cellsInProgress)
           print("\n\n\n\n\n")
           
//           if cellsInProgress.count != 0 && cellsLoadingView.isHidden == true {
//               cellsLoadingView.isHidden = false
//               cellsLoadingSpinner.startAnimating()
//
//           } else
           if cellsInProgress.count == 0 && cellsLoadingView.isHidden == false && firstScrollComplete == false {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   if self.cellsInProgress.count == 0 {
//                        UIView.transition(with: self.cellsLoadingView, duration: 0.5,
//                                          options: .transitionCrossDissolve,
//                                          animations: {
//                            self.cellsLoadingView.isHidden = true
//                            self.cellsLoadingSpinner.stopAnimating()
//                                      })
                       
                       self.firstScrollComplete = true
                       self.collectionView.scrollToItem(at: IndexPath(item: self.filteredCells.count - 1, section: 0), at: .bottom, animated: false)
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                           self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                           
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                               self.cellsLoadingSpinner.stopAnimating()
                               self.cellsLoadingView.isHidden = true
                           }
                           
                       }
                   }
                }
           }
       }
   }
   
   var idsToCheck: [String] = ["",""] // I put blank values, so that .count doesn't = 0 and the numChecked == idsToCheck.count doesn't satisfy in the default state
   var numChecked: Int = 0 {
       didSet {
           if numChecked == idsToCheck.count {
               if self.filteredCells.count == 0 {
                   self.cellsLoadingView.isHidden = true
                   self.cellsLoadingSpinner.stopAnimating()
               }
           }
       }
   }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return identifierList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("layout size")
        return CGSize(width: (view.frame.width / 2), height: ((view.frame.width / 2)-20)*1.4)
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = identifierList[indexPath.row][0]
        let numPerDay = Int(identifierList[indexPath.row][1]) ?? 1
        
        if numPerDay > 1 {
            
            let returnCell = Functions.CollectionView.getMultiCollectionViewCell(
                identifier: identifier,
                indexPath: indexPath,
                collectionView: collectionView,
                uid: uid,
                widthConstraint: view.frame.width/2 - 17.5,
                numPerDay: numPerDay,
                optionsButtonHidden: true,
                isViewOnlyMode: true
                
            ) as! MultiCollectionViewCell
            
            returnCell.tag = 0
            
            if cellsInProgress.firstIndex(of: identifier + String(returnCell.tag)) == nil {
                cellsInProgress.append(identifier + String(returnCell.tag))
            }
            
            return returnCell
            
        } else {
            let returnCell = Functions.CollectionView.getNonMultiCollectionViewCell( identifier: identifier,
                indexPath: indexPath,
                collectionView: collectionView,
                uid: uid,
                widthConstraint: view.frame.width/2 - 17.5,
                optionsButtonHidden: true,
                isEditable: false
            )
            
            returnCell.tag = 0
            
            if cellsInProgress.firstIndex(of: identifier + String(returnCell.tag)) == nil {
                cellsInProgress.append(identifier + String(returnCell.tag))
            }
            
            return returnCell
        }
        
        
    }
    
    
    //MARK: - Filter Cells
    
    var filteredCells: [[String]] = [] {
        didSet {
            print("filtered cells")
            print(filteredCells)
            identifierList = filteredCells
            itemCount = filteredCells.count
        }
    }
    
    func addMultiStatusToFilteredCells(with cellID:String) {
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(uid).collection(cellID).document("frequency")
        
        docRef.getDocument { document , error  in
            if error != nil {
                print(error)
                print(error?.localizedDescription)
                self.numChecked += 1
            } else {
                let data = document?.data()
                if let numPerDay = data!["numPerDay"] as? String {
                    self.filteredCells.append([cellID, numPerDay])
                } else {
                    // just in case, default to not-multi
                    self.filteredCells.append([cellID, "1"])
                    
                }
                self.numChecked += 1
            }
        }
    }
    
    func filterCellsUsingDates(_ ids: [String]) {
        
        filteredCells = []
        idsToCheck = ids
        numChecked = 0
        
        if ids.count == 0 {
            cellsLoadingView.isHidden = true
            cellsLoadingSpinner.stopAnimating()
        }
        //        print(12)
        for cellID in ids {
            //            print(13)
            let db = Firestore.firestore()
            let docRef = db.collection("data")
                .document(uid)
                .collection(cellID)
                .document("frequency")
            //            print(24)
            //            print(25)
            
            
            docRef.getDocument { document, error in
                //                print(26)
                if error != nil {
                    //                    print(27)
                    self.cellsLoadingView.isHidden = true
                    self.cellsLoadingSpinner.stopAnimating()
                    
                    SCLAlertView().showError("Error", subTitle: error?.localizedDescription ?? "Error retrieving data")
                    
                    //                    print(28)
                } else {
                    //                    print(29)
                    print("Cell ID: \(cellID)")
                    if let dataDescription = document?.data() {
                        let frequency = dataDescription["general"] as! String
                        let indices = dataDescription["specific"] as! [Int]
                        
                        if frequency == "Daily" {
                            //                        print(15)
                            let dayOfTheWeek = Calendar.current.dateComponents([.weekday], from: Date()).weekday! - 1
                            //                        print(16)
                            if indices.contains(dayOfTheWeek) {
                                //                            print(17)
                                self.addMultiStatusToFilteredCells(with: cellID)
                            } else {
                                self.numChecked += 1
                            }
                            
                        } else if frequency == "Weekly" {
                            //                        print(18)
                            let dayOfTheWeek = Calendar.current.dateComponents([.weekday], from: Date()).weekday! - 1
                            if indices.contains(dayOfTheWeek) {
                                //                            print(19)
                                self.addMultiStatusToFilteredCells(with: cellID)
                            } else {
                                self.numChecked += 1
                            }
                            
                        } else if frequency == "Monthly" {
                            //                        print(20)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "d"
                            let dateString = dateFormatter.string(from: Date())
                            let day = Int(dateString) ?? 0
                            if indices.contains(day) {
                                //                            print(21)
                                self.addMultiStatusToFilteredCells(with: cellID)
                            } else {
                                self.numChecked += 1
                            }
                        }
                    }
                    //                    print(30)
                }
            }
        }
        //        print(22)
    }
    //MARK: - Navigation
    
    var postSegueID: String = ""
//    var transferUid: String = ""
    var postSegueDate: Date = Date()
    var postSegueNumPerDay: Int = 1
    var postSegueTitle: String = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAllSegue" {
            let vc = segue.destination as? ViewUserViewAllViewController
            vc?.identifierList = unFilteredIdentifierList
            vc?.uid = uid
        } else if segue.identifier == "segueToMultiFromTabControl" {
            let vc = segue.destination as! MultiCellViewController
            
            vc.uid = uid
            vc.date = postSegueDate
            vc.cellID = postSegueID
            vc.numPerDay = postSegueNumPerDay
            vc.isViewOnly = true
            vc.title = postSegueTitle
            
            print("\n\n POST SEGUE TITLE: " + postSegueTitle + "\n\n\n")
        }
    }
}
