//
//  TrendsViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/29/21.
//

import UIKit
import iOSDropDown
import FirebaseAuth
import FirebaseFirestore
import SCLAlertView
import EmptyDataSet_Swift

class TrendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        dropDown.arrowColor = .label
        dropDown.rowBackgroundColor = .systemGray5
        
        if identifier != "" {
            getData(identifier: identifier)
        }
        
        //        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constants.Theme.themeColor
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 30),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.standardAppearance =  appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        
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
        
        let docRef = db.collection("data").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { document, error in
            if error != nil {
                SCLAlertView().showError("Error", subTitle: "Error retrieving user data")
                print(error?.localizedDescription)
            } else {
                
                guard let identifierList = document?.data()?["identifiers"] as? [String] else {return}
                
                for id in identifierList {
                    
                    let ref = self.db.collection("data")
                        .document(Auth.auth().currentUser!.uid)
                        .collection(id)
                        .document("info")
                    
                    ref.getDocument { document, error in
                        if error != nil {
                            SCLAlertView().showError("Error", subTitle: "Error retrieving user data")
                            print(error?.localizedDescription)
                        } else {
                            print("DOCUMENT DATA: \(document?.data())")
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
    
    @IBOutlet weak var dropDown: DropDown!
    
    
    
    
    //MARK: - Share Methods
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            SCLAlertView().showError("Error", subTitle: "No data to share")
        } else {
            let rowCount = tableView.numberOfRows(inSection: 0)
            
            var shareString:String = dropDown.optionArray[selectedIndex]
            
            var count = 0
            
            while count <= rowCount-1 {
                
                let cell = tableView.cellForRow(at: IndexPath(row: count, section: 0))
                
                if let date = cell?.textLabel?.text {
                    if let info = cell?.detailTextLabel?.text {
                        shareString += ("\n" + date + " -- " + info)
                    }
                }
                
                count += 1
            }
            
            let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
            present(vc, animated: true)
            
        }
        
    }
    
    //MARK: - Add Missing Data
    @IBAction func addMissingDataClicked(_ sender: UIButton) {
        if identifier != "" {
            performSegue(withIdentifier: "toAddDataView", sender: self)
        } else {
            SCLAlertView().showError("No item selected", subTitle: "")
        }
    }
        
    
    
    //MARK: - TableView Methods
    @IBOutlet weak var tableView: UITableView!
    
    var dataArray: [[String]] = []
    
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
            getData(identifier: identifier)
        }
    }
    
    var numPerDay: Int = 1
    
    var selectedIndex = 0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        
        cell.textLabel?.text = dataArray[indexPath.row][0]
        cell.detailTextLabel?.text = dataArray[indexPath.row][1] + " " + unitsList[selectedIndex]
        cell.tag = Int(dataArray[indexPath.row][2]) ?? 0
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTrendsDetailsVC", sender: self)
    }
    
    let db = Firestore.firestore()
    
    func getData(identifier: String) {
        
        let docRef = db.collection("data")
            .document(Auth.auth().currentUser!.uid)
            .collection(identifier)
        
        // Load NumPerDay Data
        
        docRef.document("frequency").getDocument { document , error  in
            if error != nil {
                print(error)
                print(error?.localizedDescription)
            } else {
                if let num = document?.data()?["numPerDay"] as? String {
                    self.numPerDay = Int(num) ?? 1
                }
            }
        }

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
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTrendsDetailsVC" {
            let destinationVC = segue.destination as! TrendsDetailsViewController
            
            let selectedIndexPath = self
                .tableView
                .indexPathForSelectedRow!
            
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            
            let cell = tableView.cellForRow(at: selectedIndexPath)
            
            let cellTitle = cell?.textLabel?.text
            
            if let ind = cellTitle?.firstIndex(of: ",") {
                
                
                let titleSplitArray = cellTitle?.components(separatedBy: " | ")
                print("SPLIT: \(titleSplitArray)")
                
                if let stringDate = titleSplitArray?[0], let stringTime = titleSplitArray?[1] {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    let date = dateFormatter.date(from: stringDate)
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    let time = timeFormatter.date(from: stringTime)
                    
                    destinationVC.title = stringDate
                    
                    destinationVC.cellIdentifier = identifier
                    destinationVC.searchDate = date
                    destinationVC.searchTime = time
                    destinationVC.searchTag = cell?.tag ?? 0
                }
            }
            
        } else if segue.identifier == "toAddDataView" {
            let destinationVC = segue.destination as! AddDataCustomDateViewController
            destinationVC.cellID = identifier
            destinationVC.numPerDay = numPerDay
        }
    }
    
}
