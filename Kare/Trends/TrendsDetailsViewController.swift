//
//  ViewUserTrendDetailsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 8/7/21.
//

import UIKit
import FirebaseAuth

class TrendsDetailsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Functions.CollectionView.registerCells(collectionView: collectionView)
        
        print("Trends VC did load")
        print(searchDate)
        print(searchTime)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellIdentifier: String = "errorCell"
    var searchDate: Date?
    var searchTime: Date?
    var searchTag: Int = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("layout size")
        return CGSize(width: (view.frame.width / 2)-15, height: ((view.frame.width / 2)-15)*1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let returnCell = Functions.CollectionView.getNonMultiCollectionViewCell(
            identifier: cellIdentifier,
            indexPath: indexPath,
            collectionView: collectionView,
            uid: Auth.auth().currentUser!.uid,
            widthConstraint: (view.frame.width/2)-15,
            date: searchDate ?? Date(),
            optionsButtonHidden: true,
            time: searchTime
        )
        
        returnCell.tag = searchTag
        
        return returnCell
    }
    
}
