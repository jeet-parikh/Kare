//
//  InitialViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/21/21.
//

import UIKit
import FirebaseAuth
import SCLAlertView
import AnimatedField
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate, AnimatedFieldDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var emailAnimatedField: AnimatedField!
    @IBOutlet weak var passwordAnimatedField: AnimatedField!
    
    @IBOutlet weak var blobImageView: UIImageView!
    @IBOutlet weak var blobWidthConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            emailAnimatedField.text = email
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
        emailAnimatedField.delegate = self
        passwordAnimatedField.delegate = self
        
    }
    
    func setUpElements() {
        
        blobWidthConstraint.constant = view.frame.width * 2/3
        
        loginButton.layer.cornerRadius = loginButton.frame.height/2
        
        
        // Style email field
        var emailFormat = AnimatedFieldFormat()
        
        emailFormat.counterEnabled = false
        emailFormat.highlightColor = Constants.Theme.themeColor
        emailFormat.alertEnabled = false
        emailFormat.textColor = .label.withAlphaComponent(0.8)
        emailFormat.titleColor = .label.withAlphaComponent(0.8)
        
        emailAnimatedField.type = .email
        emailAnimatedField.format = emailFormat
        emailAnimatedField.attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.7) ])
        
        // Style password field
        var passwordFormat = AnimatedFieldFormat()
        
        passwordFormat.counterEnabled = false
        passwordFormat.highlightColor = Constants.Theme.themeColor
        passwordFormat.alertEnabled = false
        passwordFormat.textColor = .label.withAlphaComponent(0.8)
        passwordFormat.titleColor = .label.withAlphaComponent(0.8)
        
        passwordAnimatedField.type = .password(0, 100)
        passwordAnimatedField.format = passwordFormat
        passwordAnimatedField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.7) ])
        passwordAnimatedField.isSecure = true
        passwordAnimatedField.showVisibleButton = true
    }
    
    func showError(_ message: String) {
        
        emailAnimatedField.resignFirstResponder()
        passwordAnimatedField.resignFirstResponder()
        
        SCLAlertView().showError("Error", subTitle: message)
    }
    
    //MARK: - UI Text Field Delegate - dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func animatedFieldDidEndEditing(_ animatedField: AnimatedField) {
        animatedField.resignFirstResponder()
    }
    
    //MARK: - Pop-up Alerts
    
    func emailNotVerified(title: String, message: String) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Ok") {
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addButton("Re-send email") {
            alert.dismiss(animated: true, completion: nil)
            
            self.user!.sendEmailVerification(completion: { (error) in
                if error != nil {
                    self.showError(error!.localizedDescription)
                } else {
                    self.emailVerificationSentAlert(title: "Email Verification Sent (Check Spam/Junk Folder)", message: "Please click on the link sent to your email account to verify your email.")
                }
            })
        }
        alert.showWarning(title, subTitle: message)
    }
    
    func emailVerificationSentAlert(title: String, message: String) {
        
        SCLAlertView().showSuccess(title, subTitle: message)
    }
    
    //MARK: - Login
    
    var user: User? = nil
    let child = SpinnerViewController()
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        emailAnimatedField.resignFirstResponder()
        passwordAnimatedField.resignFirstResponder()
        
//        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // Validate Text Fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show message
            child.willMove(toParent: nil)
            print(10)
            child.view.removeFromSuperview()
            print(11)
            child.removeFromParent()
            
            showError(error!)
        } else {
            
            // Create cleaned version of fields
            let email = emailAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let password = passwordAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let alreadyLoggedIn = (Auth.auth().currentUser != nil ? true : false)
            
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    // Couldn't sign in
                    self.child.willMove(toParent: nil)
                    print(10)
                    self.child.view.removeFromSuperview()
                    print(11)
                    self.child.removeFromParent()
                    
                    self.showError("Sorry, your email or password is incorrect. Please try again.")
                    
                } else {
                    
                    print("\n\n\n\n\n\nHEREEEEEEEE\n\n\n\n\n\n\n\n")
                    
                    self.user = Auth.auth().currentUser
                    
                    if alreadyLoggedIn == false {
                        
                        print("\n\n\n LOADING ALL NOTIFICATION INFORMATION \n\n\n")
                        
                        let db = Firestore.firestore()
                        let docRef = db.collection("data")
                        
                        docRef.getDocuments { query, error in
                            var docIDS : [String] = []
                            
                            for document in query!.documents {
                                docIDS.append(document.documentID)
                            }
                            
                            if docIDS.contains(self.user?.uid ?? " ") {
                                // only run if the document exists for that user, to prevent an error
                                
                                docRef.document(self.user?.uid ?? " ").getDocument { document, error in
                                    
                                    if error != nil {
                                        self.child.willMove(toParent: nil)
                                        print(10)
                                        self.child.view.removeFromSuperview()
                                        print(11)
                                        self.child.removeFromParent()
                                        
//                                        SCLAlertView().showError("Error", subTitle: error?.localizedDescription ?? "")
                                        print("\n\n ERROR: \(String(describing: error))")
                                    } else {
                                        
                                        if let identifiers = document?.data()?["identifiers"] as? [String] {
                                            
                                            let center = UNUserNotificationCenter.current()
                                            
                                            center.getPendingNotificationRequests { (notifications) in
                                                for item in notifications {
                                                    center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                                                }
                                            }
                                            
                                            for id in identifiers {
                                                self.scheduleNotification(cellID: id)
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        
                        print("not logged in")
                    }
                    
                    if self.user?.isEmailVerified != true {
                        // User not verified
                        self.child.willMove(toParent: nil)
                        print(10)
                        self.child.view.removeFromSuperview()
                        print(11)
                        self.child.removeFromParent()
                        
                        self.emailNotVerified(title: "Your account is not verified", message: "Look for the verification email in your inbox and click the link in that email. Also check your spam folder.")
                        
                    } else {
                        // User verified
                        // Transition to home
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
                        }
                        
//                        self.child.willMove(toParent: nil)
//                        self.child.view.removeFromSuperview()
//                        self.child.removeFromParent()
                    }
                    
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.child.willMove(toParent: nil)
        print(10)
        self.child.view.removeFromSuperview()
        print(11)
        self.child.removeFromParent()
    }
    
    func validateFields() -> String? {
        
        //check that all fields are filled in
        if emailAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    
    func scheduleNotification(cellID: String) {
        
        let db = Firestore.firestore()
        let timeRef = db.collection("data").document(user!.uid).collection(cellID)
        
        timeRef.document("frequency").getDocument { document, error in
            if error != nil {
                SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                print("\n\nERROR: \(error)\n\n")
            } else {
                let frequencySelected = (document?.data()?["general"]) as! String
                let selectedDays = (document?.data()!["specific"])! as! [Int]
                
                timeRef.document("info").getDocument { document, error in
                    if error != nil {
                        SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                        print("\n\nERROR: \(error)\n\n")
                    } else {
                        let notifTitle = (document?.data()?["title"])! as! String
                        
                        timeRef.document("notifications").getDocument { document, error in
                            if error != nil {
                                SCLAlertView().showError("Error", subTitle: error?.localizedDescription ?? "could not get localized description of error")
                                print("\n\nERROR: \(error)\n\n")
                            } else {
                                let notifTimeArray : [String:[Int]] = (document?.data()?["times"])! as! [String : [Int]]
                                
                                //-----------------\\-----------------
                                
                                let content = UNMutableNotificationContent()
                                content.title = "Reminder: \(notifTitle ?? "")"
                                content.sound = .default
                                content.body = "Please enter this out if you haven't already"
//
//                                var selectedDays: [Int] = []
//                                if frequencySelected == "Monthly" {
//                                    selectedDays = selectedCalendarDays
//                                } else {
//                                    selectedDays = getSelectedDays()
//                                }
                                
                                
                                    
                                DispatchQueue.main.async {
                                    //
                                    for day in selectedDays {
                                        var timeIteration = 0
                                        for time in notifTimeArray {
                                            timeIteration += 1
                                            let hour = time.value[0]
                                            let minute = time.value[1]
                                            
                                            if frequencySelected == "Monthly" {
                                                
                                                var dateComponents = DateComponents()
                                                dateComponents.calendar = Calendar.current
                                                
                                                dateComponents.day = day
                                                dateComponents.hour = Int(hour)
                                                dateComponents.minute = minute
                                                
                                                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                                                
                                                let notifID = "\(String(describing: self.user?.uid))_\(cellID)_\(frequencySelected)_\(day)_\(timeIteration)"
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
                                                
                                                let notifID = "\(String(describing: self.user?.uid))_\(cellID)_\(frequencySelected)_\(day)_\(timeIteration)"
                                                print("\(frequencySelected) NOTIF ID \(notifID)")
                                                
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
                                    
                    //                let db = Firestore.firestore()
                    //                let docRef = db.collection("data")
                    //                    .document(Auth.auth().currentUser!.uid)
                    //                    .collection(cellID)
                    //                    .document("notifications")
                    //
                    //                var timeMap: [String:[Int]] = [:]
                    //                var iter = 0
                    //
                    //                for time in self.notifTimeArray {
                    //                    timeMap[String(iter)] = time
                    //                    iter += 1
                    //                }
                    //                print("TIME MAP")
                    //                print(timeMap)
                    //                docRef.setData([
                    //                    "times" : timeMap
                    //                ])
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                
            }
        }
        //-----------------\\-----------------
//
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder: \(titleTextField.text ?? "")"
//        content.sound = .default
//        content.body = "Please enter this out if you haven't already"
//
//        var selectedDays: [Int] = []
//        if frequencySelected == "Monthly" {
//            selectedDays = selectedCalendarDays
//        } else {
//            selectedDays = getSelectedDays()
//        }
//
//        let center = UNUserNotificationCenter.current()
//
//        center.getPendingNotificationRequests { (notifications) in
//            for item in notifications {
//
//                if item.identifier.starts(with: "\(Auth.auth().currentUser!.uid)_\(cellID)") {
//                    center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
//                    print("REMOVING PENDING NOTIFICATION with ID: \(item.identifier)")
//                }
//            }
//            print("finished deletion")
//            print("NOTIFICATION: SELECTED DAYS ARE \(selectedDays)")
//
//            DispatchQueue.main.async {
//                //
//                for day in selectedDays {
//                    var timeIteration = 0
//                    for time in self.notifTimeArray {
//                        timeIteration += 1
//                        let hour = time[0]
//                        let minute = time[1]
//
//                        if self.frequencySelected == "Monthly" {
//
//                            var dateComponents = DateComponents()
//                            dateComponents.calendar = Calendar.current
//
//                            dateComponents.day = day
//                            dateComponents.hour = hour
//                            dateComponents.minute = minute
//
//                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//                            let notifID = "\(Auth.auth().currentUser!.uid)_\(cellID)_\(self.frequencySelected)_\(day)_\(timeIteration)"
//                            print("Monthly NOTIF ID: \(notifID)")
//
//                            let request = UNNotificationRequest(identifier: notifID, content: content, trigger: trigger)
//
//                            UNUserNotificationCenter.current().add(request) { error in
//                                if error != nil {
//                                    print("Error adding notification request:")
//                                    print(error)
//                                }
//                            }
//
//
//                        } else {
//
//                            var dateComponents = DateComponents()
//                            dateComponents.calendar = Calendar.current
//
//                            dateComponents.weekday = day + 1
//                            dateComponents.hour = hour
//                            dateComponents.minute = minute
//
//                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//                            let notifID = "\(Auth.auth().currentUser!.uid)_\(cellID)_\(self.frequencySelected)_\(day)_\(timeIteration)"
//                            print("\(self.frequencySelected) NOTIF ID \(notifID)")
//
//                            let request = UNNotificationRequest(identifier: notifID, content: content, trigger: trigger)
//
//                            UNUserNotificationCenter.current().add(request) { error in
//                                if error != nil {
//                                    print("Error adding notification request:")
//                                    print(error)
//                                }
//                            }
////                            timeIteration += 1
//                        }
//
//                    }
//                }
//
////                let db = Firestore.firestore()
////                let docRef = db.collection("data")
////                    .document(Auth.auth().currentUser!.uid)
////                    .collection(cellID)
////                    .document("notifications")
////
////                var timeMap: [String:[Int]] = [:]
////                var iter = 0
////
////                for time in self.notifTimeArray {
////                    timeMap[String(iter)] = time
////                    iter += 1
////                }
////                print("TIME MAP")
////                print(timeMap)
////                docRef.setData([
////                    "times" : timeMap
////                ])
//
//                print("SCHEDULING NOTIF TIMES FOR SAVING")
//            }
//        }
    }
    

    
}
