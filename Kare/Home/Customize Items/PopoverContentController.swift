//
//  PopoverContentController.swift
//  ProKare
//
//  Created by Jeet Parikh on 8/14/22.
//

import UIKit

class PopoverContentController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    let categoriesArray = [
        ["Fitness","figure.walk", "#6B85FF"],
        ["Health", "heart.text.square.fill", "#6B85FF"],
        ["Lifestyle", "aqi.medium", "#6B85FF"]
    ]


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        
        cell?.tintColor = UIColor(hexString: categoriesArray[indexPath.row][2])
//        cell?.imageView?.image = UIImage(systemName: categoriesArray[indexPath.row][1])
        
        
        if #available(iOS 14.0, *) {
            var content = cell?.defaultContentConfiguration()
            content?.text = categoriesArray[indexPath.row][0]
            content?.image = UIImage(systemName: categoriesArray[indexPath.row][1])?.withTintColor(UIColor(hexString: categoriesArray[indexPath.row][2]))
            cell?.contentConfiguration = content
        } else {
            // Fallback on earlier versions
            cell?.textLabel?.text = categoriesArray[indexPath.row][0]
            cell?.imageView?.image = UIImage(systemName: categoriesArray[indexPath.row][1])
            cell?.imageView?.tintColor = UIColor(hexString: categoriesArray[indexPath.row][2])
        }
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = tableView.cellForRow(at: indexPath)

        let nav = self.presentingViewController as! UINavigationController
        let vc = nav.topViewController as! CustomizationViewController
        
        vc.selectedCategoryInfoArray = categoriesArray[indexPath.row]
        
        self.dismiss(animated: true) {
//            vc.selectedCategoryInfoArray = self.categoriesArray[indexPath.row]
//            vc.selectCategoryButton.titleLabel?.text = vc.selectedCategoryInfoArray[0]
//            vc.selectCategoryButton.imageView?.image = UIImage(systemName: vc.selectedCategoryInfoArray[1])
        }
        
        self.dismiss(animated: true, completion: nil)
    }

}
