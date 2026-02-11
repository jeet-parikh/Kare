//
//  HomeViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/27/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework
import SCLAlertView
import NotificationBannerSwift
import FirebaseStorage
import SkeletonView
import FirebaseMessaging
import EmptyDataSet_Swift


class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, EmptyDataSetSource, EmptyDataSetDelegate {
    
    var itemCount = 0
    
    var identifierList: [[String]] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var currentUserName: String = Auth.auth().currentUser!.uid
    
    var unFilteredIdentifierList: [String] = []
    
    var cellArray: [UICollectionViewCell] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var dateNavigationBar: UINavigationBar!
    @IBOutlet weak var dateNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
//
//        cellsLoadingSpinner.startAnimating()
//        cellsLoadingView.isHidden = false
//
        
        collectionView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "You have no items for today. \n\nClick the + in the top right corner to add some!",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
                )
            )
                .image(UIImage(named: "sadEmptyFolderImage"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constants.Theme.themeColor
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font:
                UIFont(name: "Futura-Bold", size: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance =  appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        dateNavigationItem.title = dateFormatter.string(from: date)
        
        let dateAppearance = UINavigationBarAppearance()
        dateAppearance.backgroundColor = Constants.Theme.themeColor
        dateAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: 25),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        dateNavigationBar.standardAppearance = dateAppearance
        
        //        print(1)
        collectionView.delegate = self
        collectionView.dataSource = self
        //        print(2)
        Functions.CollectionView.registerCells(collectionView: collectionView)
        //        print(3)
        let db = Firestore.firestore()
        
        let docRef = db.collection("users1").document(Auth.auth().currentUser!.uid)
        print("2")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("3")
                let dataDescription = document.data()
                
                let firstName = dataDescription!["First Name"]! as! String
                self.navigationItem.title = "Hello " + firstName + "!"
                
            }
        }
        
//        DispatchQueue.main.async {
//            let homeListener = db.collection("data").document(Auth.auth().currentUser!.uid).addSnapshotListener { (document, error) in
//                //                print(4)
//                if let error = error {
//                    //                    print(5)
//                    self.cellsLoadingView.isHidden = false
//                    self.cellsLoadingSpinner.startAnimating()
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
//                        self.cellsLoadingView.isHidden = true
//                        self.cellsLoadingSpinner.stopAnimating()
//                    }
//                }
//            }
//
//            Constants.allSnapshotListeners.append(homeListener)
//        }
//
//        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cellsLoadingSpinner.startAnimating()
        cellsLoadingView.isHidden = false
        firstScrollComplete = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        
        db.collection("data").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
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
    
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func showSuccessfullyDeleted() {
        let leftView = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        leftView.tintColor = .white
        
        let banner = FloatingNotificationBanner(title: "Successfully deleted", leftView: leftView, style: .danger)
        banner.show(cornerRadius: 8, shadowColor: .black, shadowBlurRadius: 16, shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    
    
    
    //MARK: - Collection View Delegate and Datasource
    @IBOutlet weak var cellsLoadingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cellsLoadingSpinner: UIActivityIndicatorView!
    //"CustomSF1","CustomSF2","CustomSF3"
    
   
    var firstScrollComplete: Bool = false
    
    var cellsInProgress: [String] = [] {
        didSet {
            print("\n\n\n\n\n\n CELLS IN PROGRESS UPDATED:")
            print(cellsInProgress)
            print("\n\n\n\n\n")
            
//            if cellsInProgress.count != 0 && cellsLoadingView.isHidden == true {
//                cellsLoadingView.isHidden = false
//                cellsLoadingSpinner.startAnimating()
//
//            } else
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
//        if identifierList.count == 0 {
//            cellsLoadingView.isHidden = true
//            cellsLoadingSpinner.stopAnimating()
//        }
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
                uid: Auth.auth().currentUser!.uid,
                widthConstraint: view.frame.width/2 - 17.5,
                numPerDay: numPerDay
            ) as! MultiCollectionViewCell
            
//            returnCell.showAnimatedSkeleton()
            
            returnCell.tag = 0 
            
            if cellsInProgress.firstIndex(of: identifier + String(returnCell.tag)) == nil {
                cellsInProgress.append(identifier + String(returnCell.tag))
            }
            
            return returnCell
            
        } else {
            let returnCell = Functions.CollectionView.getNonMultiCollectionViewCell( identifier: identifier,
                indexPath: indexPath,
                collectionView: collectionView,
                uid: Auth.auth().currentUser!.uid,
                widthConstraint: view.frame.width/2 - 17.5
            )
            
//            returnCell.showAnimatedSkeleton()
            
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
            print("FILTERED CELLS: \(filteredCells)")
            identifierList = filteredCells
            itemCount = filteredCells.count
        }
    }
    
    func addMultiStatusToFilteredCells(with cellID:String) {
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(cellID).document("frequency")
        
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
                .document(Auth.auth().currentUser!.uid)
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
//
//                        if num == ids.count {
//                            // last id, went through them all
//                            print("\n\n\n\nIDS:", ids)
//                            print("Filterest Cells:", self.filteredCells)
//                            print("WENT THROUGH THEM ALL\n\n\n\n")
//                            if self.filteredCells.count == 0 {
//                                self.cellsLoadingView.isHidden = true
//                                self.cellsLoadingSpinner.stopAnimating()
//                            }
//                        }
                    }
                    //                    print(30)
                }
            }
        }
        //        print(22)
    }
    
    //MARK: - Navigation
    
    var postSegueID: String = ""
    var transferUid: String = ""
    var postSegueDate: Date = Date()
    var postSegueNumPerDay: Int = 1
    var postSegueTitle: String = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        
        if segue.identifier == "segueToAddCellViewController" {
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
            
        } else if segue.identifier == "segueToCustomizationViewEditButton" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! CustomizationViewController
            
            let db = Firestore.firestore()
            let docRef = db.collection("data")
                .document(Auth.auth().currentUser!.uid)
                .collection(self.postSegueID)
                .document("info")
            
            docRef.getDocument { (document, error) in
                if error != nil {
                    print("error finding cell descriptions")
                } else {
                    vc.titleTextField.text = document?.data()?["title"] as? String
                    vc.unitsTextField?.text = document?.data()?["units"] as? String
                }
            }
            
            vc.collectionViewIdentifier = postSegueID
            vc.adding = false
            
            if self.postSegueID.prefix(6) == "Custom" {
                vc.custom = true
                vc.customOptionSelected = String(self.postSegueID.prefix(8))
            } else {
                vc.custom = false
            }
            
        } else if segue.identifier == "friendsPopoverSegue" {
            let vc = segue.destination
            vc.popoverPresentationController?.delegate = self
            
        } else if segue.identifier == "manageItemsSegue" {
            let vc = segue.destination as! ManageItemsViewController
            vc.identifierList = unFilteredIdentifierList
            
        } else if segue.identifier == "segueToViewUserData" {
            let tab = segue.destination as! UITabBarController
            tab.title = currentUserName
            
            let itemVC = tab.viewControllers?[0] as! ViewUserItemsViewController
            itemVC.uid = transferUid
            
            let trendVC = tab.viewControllers?[1] as! ViewUserTrendsViewController
            trendVC.uid = transferUid
            
        } else if segue.identifier == "segueToMultiVC" {
            let vc = segue.destination as! MultiCellViewController
            
            vc.uid = Auth.auth().currentUser!.uid
            vc.date = postSegueDate
            vc.cellID = postSegueID
            vc.numPerDay = postSegueNumPerDay
            vc.isViewOnly = false
            vc.title = postSegueTitle
            
        }
    }
    
}

