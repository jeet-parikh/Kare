//
//  AddDataCustomDateViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 8/8/21.
//

import UIKit
import FirebaseAuth

class AddDataCustomDateViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Functions.CollectionView.registerCells(collectionView: collectionView)
        
        datePicker.maximumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        presentedViewController?.dismiss(animated: true, completion: {
            self.date = self.datePicker.date
            self.collectionView.reloadData()
        })
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
    
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numPerDay
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let returnCell = Functions.CollectionView.getNonMultiCollectionViewCell( identifier: cellID,
                                                                                 indexPath: indexPath,
                                                                                 collectionView: collectionView,
                                                                                 uid: Auth.auth().currentUser!.uid,
                                                                                 widthConstraint: view.frame.width/2 - 17.5,
                                                                                 date: date,
                                                                                 optionsButtonHidden: true )
        
        returnCell.tag = indexPath.row
        
        return returnCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.width / 2), height: ((view.frame.width / 2)-20)*1.4)
    }
    
}
