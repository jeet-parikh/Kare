//
//  CustomizationViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 4/17/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import NotificationBannerSwift
import SCLAlertView
import UserNotifications

class CustomizationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var everydayButton: UIButton!
    
    @IBOutlet weak var dailyView: UIView!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var dailyIcon: UIImageView!
    
    
    @IBOutlet weak var weeklyView: UIView!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyIcon: UIImageView!
    
    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var monthlyIcon: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var unitsTextField: UITextField!
    
    @IBOutlet weak var singleFieldButton: UIButton!
    @IBOutlet weak var yesNoButton: UIButton!
    @IBOutlet weak var textEntryButton: UIButton!
    @IBOutlet weak var customCellOptionsStackView: UIStackView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var frequencyParentView: UIView!
    @IBOutlet weak var daysParentView: UIView!
    @IBOutlet weak var monthlyOptionsView: UIView!
    
    @IBOutlet weak var daysSettingsView: UIView!
    @IBOutlet weak var monthlySettingsView: UIView!
    
    //    @IBOutlet weak var notificationTimePicker: UIDatePicker!
    @IBOutlet weak var timePickerVerticalToMonthlyView: NSLayoutConstraint!
    @IBOutlet weak var timePickerVerticalToDayView: NSLayoutConstraint!
    
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var categoryContainerView: UIView!
    @IBOutlet weak var catButtonContainerView: UIView!
    
    @IBOutlet weak var numPerDayPicker: UIPickerView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var collectionViewIdentifier: String = ""
    var adding: Bool = true
    var custom: Bool = true
    
    
    //MARK: - Existing Settings
    func applyExistingSettings() {
        let db = Firestore.firestore()
        let dataRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(collectionViewIdentifier)
        
        dataRef.document("notifications").getDocument { document, error in
            if error != nil {
                print("ERROR RETRIEVING NOTIFICATION SETTINGS FROM FIREBASE")
                print(error)
            } else {
                
                let data = document?.data()?["times"] as? [String:[Int]]
                print(data)
                self.notifTimeArray = []
                
                var iter = 0
                while iter <= (data?.count ?? 0) - 1 {
                    if let goodData = data?[String(iter)] {
                        self.notifTimeArray.append(goodData)
                    }
                    iter += 1
                }
                
                
////                iter += 1
//                print("EXISTING NOTIF SETTINGS!!")
//                print(self.notifTimeArray)
//
//                var iter = 0
//                while iter <= 3 {
//                    if let goodData = data?[String(iter)] {
//                        self.notifTimeArray.append(goodData)
//                    }
//                    iter += 1
//                    print("EXISTING NOTIF SETTINGS!!")
//                    print(self.notifTimeArray)
//                }
                
                self.notifsCollectionView.reloadData()
                self.recalculateNotifCollectionViewHeight()
                
            }
        }
        
        dataRef.document("info").getDocument { document, error in
            if error != nil {
                print("ERROR RETRIEVING CATEGORY SETTINGS FROM FIREBASE")
                print(error)
            } else {
                
                if let data = document?.data()?["categoryInfo"] as? [String] {
                    self.selectedCategoryInfoArray = data
                }                
            }
        }
        
        dataRef.document("frequency").getDocument { (document, error) in
            if error != nil {
                print("error retrieving \(self.collectionViewIdentifier) document")
            } else {
                
                let numPerDayString = document?.data()?["numPerDay"] as? String
                
                if let numPerDayInt = Int(numPerDayString ?? "") {
                    self.numPerDayPicker.selectRow(numPerDayInt-1, inComponent: 0, animated: true)
                    
//                    if numPerDayInt == 1 {
//                        self.multi = false
//                    } else {
//                        self.multi = true
//                    }
                }
                
                let frequency = document?.data()?["general"] as? String
                switch frequency {
                case "Daily":
                    self.frequencySelected = "Daily"
                    self.monthlySettingsView.isHidden = true
                    
                    self.setTimePickerConstraint(of: "Daily")
                    
                    self.setSelected(view: self.dailyView, label: self.dailyLabel, imageView: self.dailyIcon)
                    
                    if let indexList = document?.data()?["specific"] as? [Int] {
                        for index in indexList {
                            for button in [self.sundayButton, self.mondayButton, self.tuesdayButton, self.wednesdayButton, self.thursdayButton, self.fridayButton, self.saturdayButton] {
                                if button!.tag == index {
                                    button!.backgroundColor = Constants.Theme.themeColor
                                    button!.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    }
                    
                case "Weekly":
                    self.frequencySelected = "Weekly"
                    self.monthlySettingsView.isHidden = true
                    
                    self.setTimePickerConstraint(of: "Weekly")
                    
                    self.setSelected(view: self.weeklyView, label: self.weeklyLabel, imageView: self.weeklyIcon)
                    
                    if let indexList = document?.data()?["specific"] as? [Int] {
                        for index in indexList {
                            for button in [self.sundayButton, self.mondayButton, self.tuesdayButton, self.wednesdayButton, self.thursdayButton, self.fridayButton, self.saturdayButton] {
                                if button!.tag == index {
                                    button!.backgroundColor = Constants.Theme.themeColor
                                    button!.setTitleColor(.white, for: .normal)
                                }
                            }
                        }
                    }
                    
                case "Monthly":
                    self.frequencySelected = "Monthly"
                    self.monthlySettingsView.isHidden = false
                    
                    self.setTimePickerConstraint(of: "Monthly")
                    
                    self.setSelected(view: self.monthlyView, label: self.monthlyLabel, imageView: self.monthlyIcon)
                    
                    if let indexList = document?.data()?["specific"] as? [Int] {
                        self.selectedCalendarDays = indexList
                    }
                    
                    self.monthlyCollectionView.reloadData()
                    
                default:
                    self.setSelected(view: self.dailyView, label: self.dailyLabel, imageView: self.dailyIcon)
                }
            }
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthlyCollectionView.dataSource = self
        monthlyCollectionView.delegate = self
        
        notifsCollectionView.dataSource = self
        notifsCollectionView.delegate = self
        
        numPerDayPicker.delegate = self
        numPerDayPicker.dataSource = self
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if adding {
            print("SETTING: ADDING")
            //            deleteButton.removeFromSuperview()
            NSLayoutConstraint.activate([deleteButton.widthAnchor.constraint(equalToConstant: 0)])
            self.contentView.addSubview(customCellOptionsStackView)
            //            self.view.addSubview(unitsTextField)
        } else {
            print("SETTING: EDITING")
            //            self.view.addSubview(deleteButton)
            NSLayoutConstraint.deactivate([deleteButton.widthAnchor.constraint(equalToConstant: 0)])
            
            //            unitsTextField.isHidden = true
            customCellOptionsStackView.isHidden = true
            
            //            unitsTextField.removeFromSuperview()
            customCellOptionsStackView.removeFromSuperview()
        }
        
        if custom {
            titleTextField.isEnabled = true
            //            self.view.addSubview(unitsTextField)
            //            unitsTextField.isEnabled = true
            self.contentView.addSubview(customCellOptionsStackView)
            
            let db = Firestore.firestore()
            let idRef = db.collection("data").document(Auth.auth().currentUser!.uid)
            
            idRef.getDocument { document, error in
                if error != nil {
                    print("ERROR GETTING USERID DOCUMENT DATA: \(error)")
                } else {
                    self.currentIDList = document?.data()?["identifiers"] as? [String] ?? []
                    self.allIDList = document?.data()?["allIdentifiers"] as? [String] ?? []
                }
            }
            
        } else {
            titleTextField.isEnabled = false
            unitsTextField.isEnabled = false
            //            unitsTextField.removeFromSuperview()
            customCellOptionsStackView.removeFromSuperview()
        }
        
        addButton.layer.cornerRadius = addButton.frame.height / 5
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 5
        
        frequencyParentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        daysParentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        monthlyOptionsView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        for frequencyView in [dailyView, weeklyView, monthlyView] {
            frequencyView?.layer.cornerRadius = frequencyView!.frame.height / 10
            frequencyView?.layer.borderWidth = 0
            frequencyView?.layer.borderColor = Constants.Theme.themeColor.cgColor
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
            
            frequencyView?.addGestureRecognizer(tapGestureRecognizer)
        }
        
        for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
            
            button?.setTitleColor(Constants.Theme.themeColor, for: .normal)
            button?.backgroundColor = .systemBackground
            button?.layer.cornerRadius = (button?.frame.height)! / 2
            button?.layer.borderColor = Constants.Theme.themeColor.cgColor
            button?.layer.borderWidth = 0
        }
        
        setUnselected(view: dailyView, label: dailyLabel, imageView: dailyIcon)
        setUnselected(view: weeklyView, label: weeklyLabel, imageView: weeklyIcon)
        setUnselected(view: monthlyView, label: monthlyLabel, imageView: monthlyIcon)
        
        monthlySettingsView.isHidden = true
        
        singleFieldButton.layer.cornerRadius = singleFieldButton.frame.height / 2
        singleFieldButton.layer.borderColor = Constants.Theme.themeColor.cgColor
        singleFieldButton.layer.borderWidth = 1
        
        yesNoButton.layer.cornerRadius = yesNoButton.frame.height / 2
        yesNoButton.layer.borderColor = Constants.Theme.themeColor.cgColor
        yesNoButton.layer.borderWidth = 1
        
        textEntryButton.layer.cornerRadius = yesNoButton.frame.height / 2
        textEntryButton.layer.borderColor = Constants.Theme.themeColor.cgColor
        textEntryButton.layer.borderWidth = 1
        
        categoryContainerView.layer.cornerRadius = categoryContainerView.frame.height / 5
        categoryContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        catButtonContainerView.layer.cornerRadius = categoryContainerView.frame.height / 5
        catButtonContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        setTimePickerConstraint(of: "" ) // sets default constraints for distance
        
        applyExistingSettings()
        
        everydayButton.layer.cornerRadius = everydayButton.frame.height / 2
        
        setupMonthlyCollectionView()
        setupNotifCollectionView()
    }
    
    var frequencySelected: String = "Daily"
    var customOptionSelected: String = "CustomSF"
    
    var currentIDList: [String] = []
    var allIDList: [String] = [] 
    
    //MARK: - Design
    @IBAction func customCellOptionSelected(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("Single Field Selected")
            
            singleFieldButton.backgroundColor = Constants.Theme.themeColor
            singleFieldButton.setTitleColor(.white, for: .normal)
            yesNoButton.backgroundColor = .clear
            yesNoButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            textEntryButton.backgroundColor = .clear
            textEntryButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            
            customOptionSelected = "CustomSF"
        
        case 1:
            print("Text Entry Selected")
            
            textEntryButton.backgroundColor = Constants.Theme.themeColor
            textEntryButton.setTitleColor(.white, for: .normal)
            yesNoButton.backgroundColor = .clear
            yesNoButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            singleFieldButton.backgroundColor = .clear
            singleFieldButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            
            customOptionSelected = "CustomTE"
            
        case 2:
            print("Yes/No Selected")
            
            yesNoButton.backgroundColor = Constants.Theme.themeColor
            yesNoButton.setTitleColor(.white, for: .normal)
            singleFieldButton.backgroundColor = .clear
            singleFieldButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            textEntryButton.backgroundColor = .clear
            textEntryButton.setTitleColor(Constants.Theme.themeColor, for: .normal)
            
            customOptionSelected = "CustomYN"
            
        default:
            print("Error with tags on 'Single Field Button or 'Yes/No Button'")
        }
    }
    
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            print("Daily selected")
            frequencySelected = "Daily"
            
            monthlySettingsView.isHidden = true
            daysSettingsView.isHidden = false
            
            setTimePickerConstraint(of: "Daily")
            
            setSelected(view: dailyView, label: dailyLabel, imageView: dailyIcon)
            setUnselected(view: weeklyView, label: weeklyLabel, imageView: weeklyIcon)
            setUnselected(view: monthlyView, label: monthlyLabel, imageView: monthlyIcon)
            
//            daysViewHeightConstraint.constant = 135
            everydayButton.isHidden = false
            
            for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
                button?.backgroundColor = .systemBackground
                button?.setTitleColor(Constants.Theme.themeColor, for: .normal)
            }
        case 1:
            print("Weekly selected")
            frequencySelected = "Weekly"
            
            monthlySettingsView.isHidden = true
            daysSettingsView.isHidden = false
            
            setTimePickerConstraint(of: "Weekly")
            
            setSelected(view: weeklyView, label: weeklyLabel, imageView: weeklyIcon)
            setUnselected(view: dailyView, label: dailyLabel, imageView: dailyIcon)
            setUnselected(view: monthlyView, label: monthlyLabel, imageView: monthlyIcon)
            
//            daysViewHeightConstraint.constant = 82.5
            everydayButton.isHidden = true
            
            for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
                button?.backgroundColor = .systemBackground
                button?.setTitleColor(Constants.Theme.themeColor, for: .normal)
            }
        case 2:
            print("Monthly selected")
            frequencySelected = "Monthly"
            
            daysSettingsView.isHidden = true
            monthlySettingsView.isHidden = false
            
            setTimePickerConstraint(of: "Monthly")
            
            setSelected(view: monthlyView, label: monthlyLabel, imageView: monthlyIcon)
            setUnselected(view: weeklyView, label: weeklyLabel, imageView: weeklyIcon)
            setUnselected(view: dailyView, label: dailyLabel, imageView: dailyIcon)
            
        default:
            print("No tag on frequency view")
        }
    }
    
    func setTimePickerConstraint(of frequency: String) {
        switch frequency {
        case "Daily":
            timePickerVerticalToMonthlyView.priority = .defaultLow
            timePickerVerticalToDayView.priority = .defaultHigh
            timePickerVerticalToDayView.constant = 15
        case "Weekly":
            timePickerVerticalToMonthlyView.priority = .defaultLow
            timePickerVerticalToDayView.priority = .defaultHigh
            timePickerVerticalToDayView.constant = 15
        case "Monthly":
            timePickerVerticalToDayView.priority = .defaultLow
            timePickerVerticalToMonthlyView.priority = .defaultHigh
            timePickerVerticalToMonthlyView.constant = 15
        default:
            timePickerVerticalToMonthlyView.priority = .defaultLow
            timePickerVerticalToDayView.priority = .defaultHigh
            timePickerVerticalToDayView.constant = 15
        }
    }
    
    func setSelected(view: UIView, label: UILabel, imageView:UIImageView) {
        view.backgroundColor = Constants.Theme.themeColor
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        imageView.tintColor = .white
    }
    
    func setUnselected(view: UIView, label: UILabel, imageView:UIImageView) {
        view.backgroundColor = .systemBackground
        label.textColor = Constants.Theme.themeColor
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        imageView.tintColor = Constants.Theme.themeColor
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Category Popover
    
    let defaultCategoryArray = ["Click to select", "hand.tap.fill", "#6B85FF"]
    
    var selectedCategoryInfoArray : [String] = ["Click to select", "hand.tap.fill", "#6B85FF"] {
        didSet {
            print("yelllooooo")
            selectCategoryButton.setTitle("  " + selectedCategoryInfoArray[0], for: .normal)
            selectCategoryButton.tintColor = UIColor(hexString: selectedCategoryInfoArray[2])
            selectCategoryButton.setImage(UIImage(systemName: selectedCategoryInfoArray[1]), for: .normal)
            
        }
    }
    
    @IBAction func selectCategoryClicked(_ sender: UIButton) {
        
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print(selectedCategoryInfoArray)
//        selectCategoryButton.titleLabel?.text = selectedCategoryInfoArray[0]
//        selectCategoryButton.imageView?.image = UIImage(systemName: selectedCategoryInfoArray[1])
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    
    //MARK: - PickerView Methods
    var pickerArray: [String] {
        var returnArray:[String] = []
        for i in 1...24 {
            returnArray.append(String(i))
        }
        return returnArray
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 17)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = pickerArray[row]
        pickerLabel?.textColor = .label
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedNum = row + 1
        
//        if selectedNum == 1 {
//            multi = false
//        } else {
//            multi = true
//        }
        print("selected")
        print(row + 1)
    }
    
    //MARK: - Firebase methods
    
    func addItemDataToFirestore() {
        print(1)
        print("ADD ITEM TO FIRESTORE")
        let db = Firestore.firestore()
        let docRef = db.collection("data").document(Auth.auth().currentUser!.uid)
        print(2)
        
        
        if custom && adding {
            print("custom + adding")
            print(collectionViewIdentifier)
//            print(3)
            var firebaseID: String = customOptionSelected
            print("Firebase ID: ", firebaseID)
//            print(4)
            let idRef = db.collection("data").document(Auth.auth().currentUser!.uid)
//            print(5)
            idRef.getDocument { document, error in
                if error != nil {
                    print("ERROR ACCESSING USERID DATA - Custom Cell Num Choosing")
                } else {
//                    print(6)
                    var chosenNum = 1
//                    print(7)
                    let takenNums = document?.data()?[self.customOptionSelected] as? [Int]
//                    print(8)
                    
                    if takenNums?.count != 0 && takenNums != nil {
                        for num in 1... {
//                            print(9)
                            if takenNums?.contains(num) == false {
//                                print(10)
                                chosenNum = num
//                                print(11)
                                break
                            }
                        }
                    }
                    
                    
                    firebaseID = self.customOptionSelected + String(chosenNum)
                    
//                    if self.multi == true {
//                        firebaseID = "multi" + firebaseID
//                    }
                    
                    print(12)
                    docRef.setData(["identifiers": FieldValue.arrayUnion([firebaseID])], merge: true)
                    print(13)
                    docRef.setData(["allIdentifiers": FieldValue.arrayUnion([firebaseID])], merge: true)
                    print(14)
                    docRef.setData([self.customOptionSelected: FieldValue.arrayUnion([chosenNum])], merge: true)
                    print(15)
                    let dataRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(firebaseID)
                    print(16)
                    var specificData: [Int] = []
                    print(17)
                    if self.frequencySelected == "Monthly" {
                        print(18)
                        specificData = self.selectedCalendarDays
                    } else {
                        print(19)
                        specificData = self.getSelectedDays()
                    }
                    print(20)
                    dataRef.document("frequency").setData([
                        "general": self.frequencySelected,
                        "specific": specificData,
                        "numPerDay": self.pickerArray[self.numPerDayPicker.selectedRow(inComponent: 0)]
                    ])
                    
                    print(21)
                    dataRef.document("info").setData([
                        "title": self.titleTextField.text,
                        "units": self.unitsTextField.text,
                        "categoryInfo": self.selectedCategoryInfoArray
                    ])
                    print(22)
                    self.scheduleNotification(cellID: firebaseID)
                    print(23)
                }
            }
            
        } else if custom && !adding {
            
            docRef.setData(["identifiers": FieldValue.arrayUnion([collectionViewIdentifier])], merge: true)
            
            let dataRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(collectionViewIdentifier)
            
            var specificData: [Int] = []
            if self.frequencySelected == "Monthly" {
                specificData = self.selectedCalendarDays
            } else {
                specificData = self.getSelectedDays()
            }
            
            dataRef.document("frequency").setData([
                "general": self.frequencySelected,
                "specific": specificData,
                "numPerDay": self.pickerArray[self.numPerDayPicker.selectedRow(inComponent: 0)]
            ])
            
            dataRef.document("info").setData([
                "title": self.titleTextField.text,
                "units": self.unitsTextField.text,
                "categoryInfo": self.selectedCategoryInfoArray
            ])
            
            scheduleNotification(cellID: collectionViewIdentifier)
            
        } else {
            
            docRef.setData(["identifiers": FieldValue.arrayUnion([collectionViewIdentifier])], merge: true)
            docRef.setData(["allIdentifiers": FieldValue.arrayUnion([collectionViewIdentifier])], merge: true)
            
            let dataRef = db.collection("data").document(Auth.auth().currentUser!.uid).collection(collectionViewIdentifier)
            
            var specificData: [Int] = []
            if frequencySelected == "Monthly" {
                specificData = selectedCalendarDays
            } else {
                specificData = getSelectedDays()
            }
            
            dataRef.document("frequency").setData([
                "general": frequencySelected,
                "specific": specificData,
                "numPerDay": self.pickerArray[self.numPerDayPicker.selectedRow(inComponent: 0)]
            ])
            
            dataRef.document("info").setData([
                "title": self.titleTextField.text,
                "units": self.unitsTextField.text,
                "categoryInfo": self.selectedCategoryInfoArray
            ])
            
            scheduleNotification(cellID: collectionViewIdentifier)
        }
        
        performSegue(withIdentifier: "addItemSegue", sender: self)
    }
    
    
    func scheduleNotification(cellID: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(titleTextField.text ?? "")"
        content.sound = .default
        content.body = "Please enter this out if you haven't already"
        
        var selectedDays: [Int] = []
        if frequencySelected == "Monthly" {
            selectedDays = selectedCalendarDays
        } else {
            selectedDays = getSelectedDays()
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { (notifications) in
            for item in notifications {
                
                if item.identifier.starts(with: "\(Auth.auth().currentUser!.uid)_\(cellID)") {
                    center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                    print("REMOVING PENDING NOTIFICATION with ID: \(item.identifier)")
                }
            }
            print("finished deletion")
            print("NOTIFICATION: SELECTED DAYS ARE \(selectedDays)")
            
            DispatchQueue.main.async {
                //
                for day in selectedDays {
                    var timeIteration = 0
                    for time in self.notifTimeArray {
                        timeIteration += 1
                        let hour = time[0]
                        let minute = time[1]
                        
                        if self.frequencySelected == "Monthly" {
                            
                            var dateComponents = DateComponents()
                            dateComponents.calendar = Calendar.current
                            
                            dateComponents.day = day
                            dateComponents.hour = hour
                            dateComponents.minute = minute
                            
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            
                            let notifID = "\(Auth.auth().currentUser!.uid)_\(cellID)_\(self.frequencySelected)_\(day)_\(timeIteration)"
                            print("Monthly NOTIF ID: \(notifID)")
                            
                            let request = UNNotificationRequest(identifier: notifID, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if error != nil {
                                    print("Error adding notification request:")
                                    print(error)
                                }
                            }
                            
                            
                        } else {
                            
                            var dateComponents = DateComponents()
                            dateComponents.calendar = Calendar.current
                            
                            dateComponents.weekday = day + 1
                            dateComponents.hour = hour
                            dateComponents.minute = minute
                            
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            
                            let notifID = "\(Auth.auth().currentUser!.uid)_\(cellID)_\(self.frequencySelected)_\(day)_\(timeIteration)"
                            print("\(self.frequencySelected) NOTIF ID \(notifID)")
                            
                            let request = UNNotificationRequest(identifier: notifID, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if error != nil {
                                    print("Error adding notification request:")
                                    print(error)
                                }
                            }
//                            timeIteration += 1
                        }
                        
                    }
                }
                
                let db = Firestore.firestore()
                let docRef = db.collection("data")
                    .document(Auth.auth().currentUser!.uid)
                    .collection(cellID)
                    .document("notifications")
                
                var timeMap: [String:[Int]] = [:]
                var iter = 0
                
                for time in self.notifTimeArray {
                    timeMap[String(iter)] = time
                    iter += 1
                }
                print("TIME MAP")
                print(timeMap)
                docRef.setData([
                    "times" : timeMap
                ])
                
                print("SCHEDULING NOTIF TIMES FOR SAVING")
            }
        }
    }
    
    
    func getTitleUniqueness(id: String, completionHandler: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore()
        let titleRef = db.collection("data").document(Auth.auth().currentUser!.uid)
        
        titleRef.collection(id).document("info").getDocument { (document, error) in
            
            var toReturnBool: Bool? = nil {
                didSet {
                    if let bool = toReturnBool {
                        completionHandler(bool)
                    }
                }
            }
            
            guard let document = document, error == nil else { return }
            
            if document.data()?["title"] as? String == self.titleTextField.text {
                toReturnBool = false
                //                SCLAlertView().showError("Title Already in Use", subTitle: "One of your current items already uses this title. Please choose a different title.")
            } else {
                toReturnBool = true
            }
        }
        
        //        completionHandler(toReturnBool)
    }
    
    @IBAction func addItemPressed(_ sender: Any) {
        print("ADD ITEM PRESSED")
        if titleTextField.text == "" {
            SCLAlertView().showError("No Title", subTitle: "What do you want to name this item?")
            
        } else if frequencySelected == "Daily" && getSelectedDays().count == 0 {
            SCLAlertView().showError("No Days Selected", subTitle: "On what day(s) do you want to repeat this item?")
            
        } else if frequencySelected == "Weekly" && getSelectedDays().count == 0 {
            SCLAlertView().showError("No Days Selected", subTitle: "On what day do you want to repeat this item?")
            
        } else if frequencySelected == "Monthly" && selectedCalendarDays.count == 0 {
            SCLAlertView().showError("No Days Selected", subTitle: "On what days of the month do you want to repeat this item?")
            
        } else if selectedCategoryInfoArray[0] == "Click to select" {
            SCLAlertView().showError("No Category Selected", subTitle: "Select a category for this item?")
        
        } else {
            
            print(1)
            let child = SpinnerViewController()
            print(2)
            addChild(child)
            print(3)
            child.view.frame = view.frame
            print(4)
            view.addSubview(child.view)
            print(5)
            child.didMove(toParent: self)
            print(6)
            
            var foundRepeatingTitle = false
            print(7)
            
            var idsChecked = 0 {
                didSet {
                    print(8)
                    print("Changed idsChecked to \(idsChecked)")
                    if idsChecked == allIDList.count {
                        print(9)
                        child.willMove(toParent: nil)
                        print(10)
                        child.view.removeFromSuperview()
                        print(11)
                        child.removeFromParent()
                        print(12)
                        addItemDataToFirestore()
                    }
                }
            }
            print(13)
            idsChecked = 0
            print(14)
            var currentIDIndexes: [Int] = []
            print(15)
            var i = 0
            print(16)
            for _ in currentIDList {
                print(17)
                currentIDIndexes.append(i)
                print(18)
                i += 1
                print(19)
            }
            
            var currentIDIndex: Int = 0 {
                didSet {
                    print(20)
                    print("Did Set Current Index")
                    if currentIDIndexes.contains(currentIDIndex) && foundRepeatingTitle == false {
                        print(21)
                        let id = currentIDList[currentIDIndex]
                        print("Current ID LIST: \(currentIDList)")
                        print("ID: \(id)")
                        print(22)
                        if id.prefix(8) == customOptionSelected && id != collectionViewIdentifier {
                            print(23)
                            getTitleUniqueness(id: id) { isUnique in
                                print(24)
                                if isUnique == false {
                                    print(25)
                                    print("title NOT UNIQUE (current)")
                                    
                                    child.willMove(toParent: nil)
                                    print(26)
                                    child.view.removeFromSuperview()
                                    print(27)
                                    child.removeFromParent()
                                    print(28)
                                    SCLAlertView().showError("Title Already in Use",
                                                             subTitle: "One of your current items already uses this title. Please choose a different title.")
                                    foundRepeatingTitle = true
                                    return
                                    
                                } else if isUnique == true {
                                    print(29)
                                    idsChecked += 1
                                    print(30)
                                    incrementCurrentIndex()
                                    print(31)
                                }
                                
                            }
                            
                        } else {
                            print(32)
                            idsChecked += 1
                            print(33)
                            incrementCurrentIndex()
                            print(34)
                        }
                    }
                }
            }
            print(35)
            currentIDIndex = 0
            print(36)
            func incrementCurrentIndex() {
                print(37)
                print("CURRENT INDEX CHANGED TO \(currentIDIndex += 1)")
                currentIDIndex += 1
            }
            
            //-------------------------------
            print(38)
            var allIDIndexes: [Int] = []
            var a = 0
            for _ in allIDList {
                print(39)
                allIDIndexes.append(a)
                print(40)
                a += 1
                print(41)
            }
            
            var allIDIndex: Int = 0 {
                didSet {
                    print(42)
                    print("Did Set All Ids")
                    if allIDIndexes.contains(allIDIndex) && foundRepeatingTitle == false {
                        print(43)
                        let id = allIDList[allIDIndex]
                        print("All ID List: \(allIDList)")
                        print("allID: \(id)")
                        print(44)
                        if id.prefix(8) == customOptionSelected && currentIDList.contains(id) == false {
                            print(45)
                            getTitleUniqueness(id: id) { isUnique in
                                print(46)
                                if isUnique == false {
                                    print(47)
                                    child.willMove(toParent: nil)
                                    child.view.removeFromSuperview()
                                    child.removeFromParent()
                                    print(48)
                                    print("title NOT UNIQUE (all)")
                                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                                    print(49)
                                    alert.addButton("Reactivate") {
                                        print(49)
                                        let db = Firestore.firestore()
                                        
                                        let docRef = db.collection("data").document(Auth.auth().currentUser!.uid)
                                        
                                        docRef.setData(["identifiers": FieldValue.arrayUnion([id])], merge: true)
                                        
                                        var specificData: [Int] = []
                                        if self.frequencySelected == "Monthly" {
                                            specificData = self.selectedCalendarDays
                                        } else {
                                            specificData = self.getSelectedDays()
                                        }
                                        
                                        docRef.collection(id).document("frequency").setData([
                                            "general": self.frequencySelected,
                                            "specific": specificData
                                        ])
                                        
                                        docRef.collection(id).document("info").setData([
                                            "title": self.titleTextField.text,
                                            "units": self.unitsTextField.text
                                        ])
                                        
                                        alert.dismiss(animated: true) {
                                            self.performSegue(withIdentifier: "addItemSegue", sender: self)
                                        }
                                        
                                    }
                                    print(50)
                                    alert.addButton("No thanks") {
                                        alert.dismiss(animated: true, completion: nil)
                                    }
                                    print(51)
                                    alert.showWarning("Item Previously Used",
                                                      subTitle: "You had previously added an item with the same title. Would you like to reactivate it?")
                                    print(52)
                                    foundRepeatingTitle = true
                                    print(53)
                                    return
                                    
                                } else if isUnique == true {
                                    print(54)
                                    idsChecked += 1
                                    print(55)
                                    incrementAllIndex()
                                    print(56)
                                }
                            }
                            
                        } else {
                            print(57)
                            if currentIDList.contains(id) == false {
                                print(58)
                                idsChecked += 1
                                print(59)
                            }
                            print(60)
                            incrementAllIndex()
                            print(61)
                        }
                    }
                }
            }
            print(62)
            allIDIndex = 0
            print(63)
            func incrementAllIndex() {
                print(64)
                allIDIndex += 1
            }
            
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Yes") {
            
            let db = Firestore.firestore()
            let docRef = db.collection("data").document(Auth.auth().currentUser!.uid)
            
            docRef.updateData([
                "identifiers": FieldValue.arrayRemove([self.collectionViewIdentifier]),
                self.collectionViewIdentifier: FieldValue.delete()
            ])
            
            let frequencyRef = docRef.collection(self.collectionViewIdentifier).document("frequency")
            frequencyRef.updateData([
                "general": FieldValue.delete(),
                "specific": FieldValue.delete()
            ])
            
            let center = UNUserNotificationCenter.current()
            
            center.getPendingNotificationRequests { (notifications) in
                for item in notifications {
                    
                    if item.identifier.starts(with: "\(Auth.auth().currentUser!.uid)_\(self.collectionViewIdentifier)") {
                        center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                        print("REMOVING PENDING NOTIFICATION with ID: \(item.identifier)")
                    }
                }
            }
            
            alert.dismiss(animated: true) {
                self.performSegue(withIdentifier: "deleteItemSegue", sender: self)
            }
            
        }
        
        alert.addButton("Cancel") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showWarning("Are you sure you want to delete this item?", subTitle: "You will stop recieving notifications for this item.")
        
    }
    
    @IBAction func weekdayButtonPressed(_ sender: UIButton) {
        if frequencySelected == "Daily" {
            if sender.backgroundColor == UIColor.systemBackground {
                // previously deselected, clicked --> selected
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = Constants.Theme.themeColor
            } else {
                // previously selected, clicked --> deselected
                sender.setTitleColor(Constants.Theme.themeColor, for: .normal)
                sender.backgroundColor = .systemBackground
            }
        } else if frequencySelected == "Weekly" {
            for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
                if button == sender {
                    button?.setTitleColor(.white, for: .normal)
                    button?.backgroundColor = Constants.Theme.themeColor
                } else {
                    button?.setTitleColor(Constants.Theme.themeColor, for: .normal)
                    button?.backgroundColor = .systemBackground
                }
            }
        }
        
        let selected = getSelectedDays()
        print(selected)
    }
    
    @IBAction func everydayButtonPressed(_ sender: UIButton) {
        for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
            button?.backgroundColor = Constants.Theme.themeColor
            button?.setTitleColor(.white, for: .normal)
        }
    }
    
    func getSelectedDays() -> [Int] {
        var selected: [Int] = []
        for button in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
            if button?.backgroundColor == Constants.Theme.themeColor {
                selected.append(button!.tag)
            }
        }
        return selected
    }
    
    //MARK: - Collection View Methods
    
    @IBOutlet weak var monthlyCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notifsCollectionView: UICollectionView!
    @IBOutlet weak var notifHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var minusNotifButton: UIButton!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == monthlyCollectionView {
            return 31
        } else {
            return notifTimeArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == monthlyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
            cell.daysNumberLabel.text = String(indexPath.row+1)
            cell.layer.cornerRadius = cell.frame.height/2
            
            if selectedCalendarDays.contains(indexPath.row + 1) {
                cell.backgroundColor = Constants.Theme.themeColor
                cell.daysNumberLabel.textColor = .white
            } else {
                cell.backgroundColor = .systemBackground
                cell.daysNumberLabel.textColor = Constants.Theme.themeColor
            }
            return cell
            
        } else {
            // notif collection view
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notifCell", for: indexPath) as! NotifTimeCollectionViewCell
            
            cell.layer.cornerRadius = cell.frame.height / 5
            cell.tag = indexPath.row
            
            cell.setTime(hour: notifTimeArray[indexPath.row][0], min: notifTimeArray[indexPath.row][1])
            
            return cell
        }
    }
    
    var selectedCalendarDays: [Int] = []
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == monthlyCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
            if cell.backgroundColor == .systemBackground {
                cell.backgroundColor = Constants.Theme.themeColor
                cell.daysNumberLabel.textColor = .white
                
                // add to selected
                selectedCalendarDays.append(indexPath.row + 1)
                selectedCalendarDays = selectedCalendarDays.sorted()
                print(selectedCalendarDays)
                
            } else {
                cell.backgroundColor = .systemBackground
                cell.daysNumberLabel.textColor = Constants.Theme.themeColor
                
                // remove from selected
                let index = selectedCalendarDays.firstIndex(of: indexPath.row + 1)
                selectedCalendarDays.remove(at: index!)
                print(selectedCalendarDays)
            }
        }
        
        else {
            // notif collection view
            
        }
    }
    
    var notifTimeArray: [[Int]] = [] {
        didSet {
            if notifTimeArray.count == 0 {
                minusNotifButton.isHidden = true
                recalculateNotifCollectionViewHeight()
//                notifHeightConstraint.constant = 0
            } else {
                minusNotifButton.isHidden = false
                recalculateNotifCollectionViewHeight()
//                notifHeightConstraint.constant = 10 + (0.4*(view.frame.width-75)/3)
            }
        }
    }
    
    func recalculateNotifCollectionViewHeight() {
        let height = notifsCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        if notifTimeArray.count == 0 {
            notifHeightConstraint.constant = height
        } else {
            notifHeightConstraint.constant = height + 10
        }
        
        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
    }
    
    @IBAction func addNotifPressed(_ sender: UIButton) {
        notifTimeArray.append([17,0])
        notifsCollectionView.reloadData()
        recalculateNotifCollectionViewHeight()
//        if notifTimeArray.count >= 4 {
//            // cells will go to next line, which we dont want (4 max)
//            SCLAlertView().showError("Notification Limit", subTitle: "You can have a max of 4 notification times")
//        } else {
//            notifTimeArray.append([17,0])
//            notifsCollectionView.reloadData()
//            recalculateNotifCollectionViewHeight()
//        }
    }
    
    @IBAction func minusNotifButtonPressed(_ sender: UIButton) {
        print("minus pressed")
        print(notifTimeArray)
        notifTimeArray.popLast()
        notifsCollectionView.reloadData()
        recalculateNotifCollectionViewHeight()
    }
    
    
    func setupMonthlyCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (monthlyOptionsView.frame.width - 100)/8,
                                 height: (monthlyOptionsView.frame.width - 100)/8)
        monthlyCollectionView!.collectionViewLayout = layout
        
        collectionViewHeightConstraint.constant = 4 * (monthlyOptionsView.frame.width - 80)/8 + 10
    }
    
    func setupNotifCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (view.frame.width-75)/3,
                                 height: (0.3*(view.frame.width-55)/3))
        notifsCollectionView!.collectionViewLayout = layout
        
        if notifTimeArray.count == 0 {
            minusNotifButton.isHidden = true
            recalculateNotifCollectionViewHeight()
//            notifHeightConstraint.constant = 0
        } else {
            minusNotifButton.isHidden = false
            recalculateNotifCollectionViewHeight()
//            notifHeightConstraint.constant = 10 + (0.3*(view.frame.width-75)/3)
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue" {
            let vc = segue.destination
            
            let leftView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
            leftView.tintColor = .white
            
            let banner = FloatingNotificationBanner(title: "Successfully saved", leftView: leftView, style: .success)
            banner.show(on: vc, cornerRadius: 8, shadowColor: .black, shadowBlurRadius: 16, shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            
        } else if segue.identifier == "deleteItemSegue" {
            let vc = segue.destination
            
            let leftView = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
            leftView.tintColor = .white
            
            let banner = FloatingNotificationBanner(title: "Successfully deleted", leftView: leftView, style: .danger)
            banner.show(on: vc, cornerRadius: 8, shadowColor: .black, shadowBlurRadius: 16, shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        } else if segue.identifier == "categoryPopoverSegue" {
            let vc = segue.destination
            vc.popoverPresentationController?.delegate = self
            vc.preferredContentSize = CGSize(width: 200, height: 3*44.5)
        }
    }
    
}


