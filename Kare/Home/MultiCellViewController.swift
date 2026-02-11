//
//  MultiCellViewController.swift
//  ProKare
//
//  Created by Jeet Parikh on 1/18/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MultiCellViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var dateNavigationBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        cellsLoadingSpinner.startAnimating()
        cellsLoadingView.isHidden = false
        
        Functions.CollectionView.registerCells(collectionView: collectionView)
        
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
        
    }
    
    var cellID: String = "" {
        didSet {
            if let cv = collectionView {
                cv.reloadData()
            }
        }
    }
    
    var numPerDay: Int = 1 {
        didSet {
            print("numPerDay: \(numPerDay)")
            if let cv = collectionView {
                cv.reloadData()
            }
        }
    }
    
    var date: Date = Date() {
        didSet {
            if let cv = collectionView {
                cv.reloadData()
            }
        }
    }
    
    var uid: String = Auth.auth().currentUser!.uid {
        didSet {
            print("Set UID to " + uid)
            if let cv = collectionView {
                cv.reloadData()
            }
        }
    }
    
    var isViewOnly: Bool = false {
        didSet {
            print("Set ViewOnly to: ", isViewOnly)
            if let cv = collectionView {
                cv.reloadData()
            }
        }
    }
    
    
    //MARK: - Collection View
    @IBOutlet weak var cellsLoadingView: UIView!
    @IBOutlet weak var cellsLoadingSpinner: UIActivityIndicatorView!
    
    var cellsInProgress: [String] = [] {
        didSet {
            print("\n\n\n\n\n\n MULTI VC -- IN PROGRESS UPDATED:")
            print(cellsInProgress)
            print("\n\n\n\n\n")

//            if cellsInProgress.count != 0 && cellsLoadingView.isHidden == true {
//                cellsLoadingView.isHidden = false
//                cellsLoadingSpinner.startAnimating()
//
//            } else
            if cellsInProgress.count == 0 && cellsLoadingView.isHidden == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.cellsInProgress.count == 0 {
//                        UIView.transition(with: self.cellsLoadingView, duration: 0.5,
//                                          options: .transitionCrossDissolve,
//                                          animations: {
//                            self.cellsLoadingView.isHidden = true
//                            self.cellsLoadingSpinner.stopAnimating()
//                                      })

                        self.cellsLoadingSpinner.stopAnimating()
                        self.cellsLoadingView.isHidden = true
                    }
                 }
            }
        }
    }
    
//    var idsToCheck: [String] = ["",""] // I put blank values, so that .count doesn't = 0 and the numChecked == idsToCheck.count doesn't satisfy in the default state
//    var numChecked: Int = 0 {
//        didSet {
//            if numChecked == idsToCheck.count {
//                self.cellsLoadingView.isHidden = true
//                self.cellsLoadingSpinner.stopAnimating()
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numPerDay
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let returnCell = Functions.CollectionView.getNonMultiCollectionViewCell( identifier: cellID,
            indexPath: indexPath,
            collectionView: collectionView,
            uid: uid,
            widthConstraint: view.frame.width/2 - 17.5,
            optionsButtonHidden: true,
            isEditable: !isViewOnly
        )
        
        returnCell.tag = indexPath.row
        
        if cellsInProgress.firstIndex(of: cellID + String(returnCell.tag)) == nil {
            cellsInProgress.append(cellID + String(returnCell.tag))
        }
        
        return returnCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.width / 2), height: ((view.frame.width / 2)-20)*1.4)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
