//
//  passwordResetViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/27/21.
//

import UIKit
import FirebaseAuth
import SCLAlertView
import AnimatedField

class PasswordResetViewController: UIViewController {
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var emailAnimatedField: AnimatedField!
    
    var emailPreFill = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        emailAnimatedField.text = emailPreFill
        
        resetPasswordButton.layer.cornerRadius = resetPasswordButton.frame.height/2
    }
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        
        let cleanedEmail = emailAnimatedField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if cleanedEmail == "" {
            
            showError("Fill out all fields")
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: cleanedEmail!) { (error) in
                
                if error != nil {
                    self.showError(error!.localizedDescription)
                } else {
                    self.passwordResetSentAlert(title: "Password Reset Email Sent", message: "Please click on the link sent to your email account to reset your password. Be sure to check you Spam/Junk folder.")
                }
            }
        }
    }
    
    func showError(_ message: String) {
        
        SCLAlertView().showError("Error", subTitle: message)
    }
    
    func passwordResetSentAlert(title: String, message: String) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Ok") {
            alert.dismiss(animated: true, completion: nil)
            
            if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "passwordResetSignOutSegue", sender: self)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
            
        }
        
        alert.showSuccess(title, subTitle: message)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordResetSignOutSegue" {
            do {
                
                for listener in Constants.allSnapshotListeners {
                    listener.remove()
                }
                
                try Auth.auth().signOut()
                
                let center = UNUserNotificationCenter.current()
                
                center.getPendingNotificationRequests { (notifications) in
                    
                    for item in notifications {
                        print("REMOVING all notifications")
                        center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                    }
                    
                }
                
            } catch {
                SCLAlertView().showError("Error Signing Out", subTitle: "")
            }
            
        }
    }
    
}
