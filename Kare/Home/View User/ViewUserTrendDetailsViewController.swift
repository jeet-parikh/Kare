//
//  ViewUserTrendDetailsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 8/17/21.
//

import UIKit

class ViewUserTrendDetailsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Functions.CollectionView.registerCells(collectionView: collectionView)
        
        print("Trends VC did load")
        print(searchDate)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellIdentifier: String = "errorCell"
    var uid: String = ""
    var searchDate: Date?
    
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
            uid: uid,
            widthConstraint: (view.frame.width/2)-15,
            date: searchDate ?? Date(),
            optionsButtonHidden: true,
            isEditable: false
        )
        
        return returnCell
    }
    
}
