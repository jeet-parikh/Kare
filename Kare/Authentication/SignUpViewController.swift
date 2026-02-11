//
//  SignUpViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/22/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import SCLAlertView
import AnimatedField

class SignUpViewController: UIViewController, AnimatedFieldDelegate {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var firstNameAnimatedField: AnimatedField!
    @IBOutlet weak var lastNameAnimatedField: AnimatedField!
    @IBOutlet weak var emailAnimatedField: AnimatedField!
    @IBOutlet weak var passwordAnimatedField: AnimatedField!
    @IBOutlet weak var reEnterPasswordAnimatedField: AnimatedField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameAnimatedField.delegate = self
        lastNameAnimatedField.delegate = self
        emailAnimatedField.delegate = self
        passwordAnimatedField.delegate = self
        reEnterPasswordAnimatedField.delegate = self
        
        setUpElements()
    }
    
    func setUpElements() {
        
        signUpButton.layer.cornerRadius = signUpButton.frame.height/2
        
        // Style first name field
        var firstNameFormat = AnimatedFieldFormat()
        firstNameFormat.counterEnabled = false
        firstNameFormat.highlightColor = Constants.Theme.themeColor
        firstNameFormat.alertEnabled = false
        firstNameFormat.textColor = .label.withAlphaComponent(0.8)
        firstNameFormat.titleColor = .label.withAlphaComponent(0.8)
        
        firstNameAnimatedField.type = .username(0, 100)
        firstNameAnimatedField.format = firstNameFormat
        firstNameAnimatedField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.7) ])
        
        // Style last name field
        var lastNameFormat = AnimatedFieldFormat()
        lastNameFormat.counterEnabled = false
        lastNameFormat.highlightColor = Constants.Theme.themeColor
        lastNameFormat.alertEnabled = false
        lastNameFormat.textColor = .label.withAlphaComponent(0.8)
        lastNameFormat.titleColor = .label.withAlphaComponent(0.8)
        
        lastNameAnimatedField.type = .username(0, 100)
        lastNameAnimatedField.format = firstNameFormat
        lastNameAnimatedField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.7) ])
        
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
        
        // Style re-enter password field
        var reEnterPasswordFormat = AnimatedFieldFormat()
        
        reEnterPasswordFormat.counterEnabled = false
        reEnterPasswordFormat.highlightColor = Constants.Theme.themeColor
        reEnterPasswordFormat.alertEnabled = false
        reEnterPasswordFormat.textColor = .label.withAlphaComponent(0.8)
        reEnterPasswordFormat.titleColor = .label.withAlphaComponent(0.8)
        
        reEnterPasswordAnimatedField.type = .password(0, 100)
        reEnterPasswordAnimatedField.format = passwordFormat
        reEnterPasswordAnimatedField.attributedPlaceholder = NSAttributedString(string: "Re-enter password", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.7) ])
        reEnterPasswordAnimatedField.isSecure = true
        reEnterPasswordAnimatedField.showVisibleButton = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //MARK: - Sign Up
    
    var user: User? = nil
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        self.isEditing = false
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show message
            showError(error!)
            
        } else {
            // Create cleaned versions of the data
            let firstName = firstNameAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            let lastName = lastNameAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            let email = emailAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let password = passwordAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            // Create User
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError(err?.localizedDescription ?? "Error creating user")
                    
                } else {
                    
                    // User was created successfully, now store data
                    let db = Firestore.firestore()
                    db.collection("users1").document(result!.user.uid).setData(["First Name":firstName, "Last Name":lastName, "Email":email, "Profile Image URL":""]) { (error) in
                        if error != nil {
                            // show error message
                            self.showError("User data could not be saved")
                        }
                    }
                    
                    db.collection("friends").document(result!.user.uid).setData(["Followers":[], "Friend Requests":[], "Pending Friends":[], "Following": []]) { (error) in
                        if error != nil {
                            // show error message
                            self.showError("User data could not be saved")
                        }
                    }
                    
                    // Verify Email
                    self.user = Auth.auth().currentUser!
                    self.user!.sendEmailVerification(completion: { (error) in
                        if error != nil {
                            self.showError(error!.localizedDescription)
                        } else {
                            self.emailVerificationSentAlert(title: "Email Verification Sent (Check Spam/Junk Folder)", message: "Please click on the link sent to your email account to verify your email.")
                        }
                    })
                }
            }
        }
    }
    
    //MARK: - Pop-up Alerts
    
    func emailVerificationSentAlert(title: String, message: String) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
        alert.addButton("Ok") {
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.showNotice(title, subTitle: message)
    }
    
    func showError(_ message: String) {
        
        firstNameAnimatedField.resignFirstResponder()
        lastNameAnimatedField.resignFirstResponder()
        emailAnimatedField.resignFirstResponder()
        passwordAnimatedField.resignFirstResponder()
        reEnterPasswordAnimatedField.resignFirstResponder()
        
        SCLAlertView().showError("Error", subTitle: message)
    }
    //MARK: - Form Validation
    
    func isPasswordValid(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        
        // at least one digit
        // 6 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[0-9]).{6,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    // Check the fields and validate that the data is correct. If everything is correct,t his method returns nil. Otherwise, it returns the error message.
    func validateFields() -> String? {
        
        //check that all fields are filled in
        if firstNameAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            reEnterPasswordAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        let cleanedPassword = passwordAnimatedField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPasswordValid(testStr: cleanedPassword) == false {
            return "Please make sure your password satified the follwing requireemnts \n\n1. At least 6 characters \n2. Contains a number"
        }
        
        // Check if Password is consistent (same in password and re-enter password fields)
        if passwordAnimatedField.text! != reEnterPasswordAnimatedField.text! {
            return "The passwords you entered do not match. Please re-enter your password."
        }
        
        return nil
    }
    
    
}
