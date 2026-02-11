//
//  Constants.swift
//  Kare
//
//  Created by Niraj Parikh on 3/23/21.
//

import UIKit
import FirebaseFirestore

struct Constants {
    
    struct Storyboard {
        
        static let homeViewController = "HomeVC"
        
    }
    
    struct Theme {
        static let themeColor = UIColor(red: 0.42, green: 0.52, blue: 1.0, alpha: 1.00)
    }
    
    struct CollectionViewData {
        public static let classes: [String: UICollectionViewCell] = ["bloodPressureCell": BloodPressureCollectionViewCell()]
    }
    
    static var allSnapshotListeners:[ListenerRegistration] = []
    static var cellsInProgress: [String] = [] {
        didSet {
            print("\n\n\n\n\n\n CELLS IN PROGRESS UPDATED:")
            print(cellsInProgress)
            print("\n\n\n\n\n")
//            if cellsInProgress.count != 0 && cellsLoadingView.isHidden == true {
//                cellsLoadingView.isHidden = false
//                cellsLoadingSpinner.startAnimating()
//
//            } else if cellsInProgress.count == 0 {
//                cellsLoadingSpinner.stopAnimating()
//                cellsLoadingView.isHidden = true
//            }
        }
    }
    
}
