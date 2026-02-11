//
//  ViewUserTrendsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 5/3/21.
//

import UIKit
import iOSDropDown
//import FirebaseAuth
import FirebaseFirestore
import SCLAlertView
import EmptyDataSet_Swift

class ViewUserTrendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        dropDown.arrowColor = .label
        dropDown.rowBackgroundColor = .systemGray5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.font = UIFont.systemFont(ofSize: 22)
        dropDown.rowHeight = 45
        dropDown.listHeight = 250
        dropDown.arrowColor = .label
        dropDown.rowBackgroundColor = .systemGray5
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.emptyDataSetView { view in
            view.titleLabelString(
                NSAttributedString(
                    string: "No Data",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
                )
            )
                .image(UIImage(named: "no data ufo"))
                .shouldFadeIn(true)
                .isTouchAllowed(true)
        }
        
        let docRef = db.collection("data").document(uid)
        docRef.getDocument { document, error in
            if error != nil {
                SCLAlertView().showError("Error", subTitle: "Error retrieving user data")
                print(error?.localizedDescription)
            } else {
                
                guard let identifierList = document?.data()?["identifiers"] as? [String] else {return}
                
                for id in identifierList {
                    
                    let ref = self.db.collection("data")
                        .document(self.uid)
                        .collection(id)
                        .document("info")
                    
                    ref.getDocument { document, error in
                        if error != nil {
                            SCLAlertView().showError("Error", subTitle: "Error retrieving user data")
                            print(error?.localizedDescription)
                        } else {
                            self.titleList.append(document?.data()?["title"] as! String)
                            self.unitsList.append(document?.data()?["units"] as! String)
                            
                            self.idList.append(id)
                            
                            self.dropDown.selectedIndex = 0
                            self.dropDown.text = self.titleList[0]
                            
                            self.identifier = self.idList[0]
                            //                            self.getCellIdentifierFromTitle(title: self.dropDown.text!)
                        }
                    }
                }
            }
        }
        
        dropDown.isSearchEnable = false
        dropDown.selectedRowColor = Constants.Theme.themeColor.withAlphaComponent(0.6)
        
        dropDown.didSelect { selectedText, index, id in
            print("Trend Drop Down - Selected: \(selectedText)")
            //            self.getCellIdentifierFromTitle(title: selectedText)
            self.identifier = self.idList[index]
            self.selectedIndex = index
        }
        
        //        if dropDown.text != "" {
        //            getCellIdentifierFromTitle(title: dropDown.text!)
        //        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = Constants.Theme.themeColor
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        if dropDown.text != "" {
        //            getCellIdentifierFromTitle(title: dropDown.text!)
        //        }
    }
    
    @IBOutlet weak var dropDown: DropDown!
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String = ""
    
    public var dataArray: [[String]] = [] {
        didSet {
            //            tableView.reloadData()
        }
    }
    
    var titleList: [String] = [] {
        didSet {
            dropDown.optionArray = titleList
        }
    }
    
    var unitsList: [String] = []
    
    var idList: [String] = []
    
    var identifier: String = "" {
        didSet {
            //            print(5)
            getData(
                identifier: identifier
                //                index: selectedIndex,
                //                uid: uid,
                //                tableView: tableView
            )
            
            print(dataArray)
            
            tableView.reloadData()
        }
    }
    
    var selectedIndex: Int = 0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewUserDateCell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row][0]
        cell.detailTextLabel?.text = dataArray[indexPath.row][1] + " " + unitsList[selectedIndex]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArray.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        return dataArray.count
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "segueToViewUserTrendsDetailsVC", sender: self)
//    }
    
    let db = Firestore.firestore()
    
    func getData(identifier: String) {
        
        let docRef = db.collection("data")
            .document(uid)
            .collection(identifier)
        
        // Load NumPerDay Data
        
//        docRef.document("frequency").getDocument { document , error  in
//            if error != nil {
//                print(error)
//                print(error?.localizedDescription)
//            } else {
//                if let num = document?.data()?["numPerDay"] as? String {
//                    self.numPerDay = Int(num) ?? 1
//                }
//            }
//        }

        // Load TableView Data
        
        docRef.order(by: FieldPath.documentID()).getDocuments { querySnapshot, error in
            if error != nil {
                SCLAlertView().showError("Error", subTitle: "Error retrieving data")
            } else {
                //                print(7)
                self.dataArray = []
                if let dataDescription = querySnapshot?.documents {
                    for document in dataDescription {
                        if document.documentID == "frequency" || document.documentID == "info" || document.documentID == "notifications" {
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
                        
                        
                        if let documentData = document.data()["data"] as? [String:[String]] {
                            let keysArray = documentData.keys.sorted()
                            var timeAndKey: [String:String] = [:]
                            
                            for key in keysArray {
                                
                                let time = documentData[key]?[0]
                                timeAndKey[time ?? "no time"] = key
                                
                            }
                            
                            let timeArray = timeAndKey.keys.sorted()
                            
                            for timeStamp in timeArray {
                                
                                let index = timeAndKey[timeStamp]
                                
                                let data = documentData[index!]! as [String]
                                
                                var dataString = ""

                                var iter = 0
                                for i in data {
                                    if iter == 0 {
                                        // do nothing
                                    } else if iter == 1 {
                                        dataString += i
                                    } else {
                                        dataString += " | \(i)"
                                    }
                                    iter += 1
                                }

                                let timeFormatterGet = DateFormatter()
                                timeFormatterGet.dateFormat = "HH.mm"
                                print("time stamp: \(timeStamp)")
                                let timeValue = timeFormatterGet.date(from: timeStamp)

                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "h:mm a"
                                let formattedTime = timeFormatter.string(from: timeValue!)

                                let finalDateAndTime = formattedDate + " | " + formattedTime

                                self.dataArray.insert([finalDateAndTime, dataString, index ?? "0"], at: 0)

                                self.tableView.reloadData()
                                
                            }
                            
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
//    func getData(
//        identifier: String
//        //        index: Int
//    ) {
//        let docRef = db.collection("data")
//            .document(uid)
//            .collection(identifier)
//        //        print(6)
//        docRef.order(by: FieldPath.documentID()).getDocuments { querySnapshot, error in
//            if error != nil {
//                SCLAlertView().showError("Error", subTitle: "Error retrieving data")
//            } else {
//                //                print(7)
//                self.dataArray = []
//                if let dataDescription = querySnapshot?.documents {
//                    for document in dataDescription {
//                        if document.documentID == "frequency" || document.documentID == "info" || document.documentID == "notifications" {
//                            continue
//                        }
//                        //                        print(8)
//                        let date = document.documentID
//
//                        let dateFormatterGet = DateFormatter()
//                        dateFormatterGet.dateFormat = "yyyy.MM.dd"
//
//                        let dateValue = dateFormatterGet.date(from: date)
//
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateFormat = "MMM d, yyyy"
//                        let formattedDate = dateFormatter.string(from: dateValue!)
//
//                        var string = ""
//                        var iteration = 0
//
//                        print("Document Data: \(document.data())")
//                        //                        print(9)
//                        let data = document.data()
//                        let sortedKeys = data.keys.sorted()
//                        for key in sortedKeys {
//                            //                            print(10)
//                            if iteration == 0 {
//                                //                                print(12)
//                                string += data[key] as! String
//                                iteration += 1
//                            } else {
//                                //                                print(13)
//                                string += " | \(data[key] as! String)"
//                                iteration += 1
//                            }
//                        }
//
//                        //                        string += " " + self.unitsList[index]
//                        //                        print(14)
//                        self.dataArray.insert([formattedDate,string], at: 0)
//                        //                        print(15)
//                        self.tableView.reloadData()
//                    }
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
//
    //    func getCellIdentifierFromTitle(title: String ) {
    ////        print(3)
    //        let docRef = db.collection("data").document("Cell Descriptions").collection("information")
    ////        print(4)
    //        docRef.whereField("Title", isEqualTo: title).getDocuments { querySnapshot, error in
    //            if error != nil {
    //                SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
    //            } else {
    ////                print(5)
    //                let document = querySnapshot?.documents[0]
    //                self.identifier = document!.documentID
    //            }
    //        }
    //    }
    
    //MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "segueToViewUserTrendsDetailsVC" {
//            let destinationVC = segue.destination as! ViewUserTrendDetailsViewController
//
//            let selectedIndexPath = self.tableView.indexPathForSelectedRow!
//            let cell = tableView.cellForRow(at: selectedIndexPath)
//
//            tableView.deselectRow(at: selectedIndexPath, animated: true)
//
//            guard let stringDate = cell?.textLabel?.text else { return }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MMM d, yyyy"
//            let date = dateFormatter.date(from: stringDate)
//
//
//            destinationVC.title = cell?.textLabel?.text
//
//            destinationVC.cellIdentifier = identifier
//            destinationVC.searchDate = date!
//            destinationVC.uid = uid
//        }
//    }
    
}
