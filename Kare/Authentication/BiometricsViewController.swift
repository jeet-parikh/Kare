//
//  BiometricsViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/23/21.
//

import UIKit
import LocalAuthentication
import FirebaseAuth
import AnimatedField

class BiometricsViewController: UIViewController {
    
    @IBOutlet weak var emailAnimatedField: AnimatedField!
    @IBOutlet weak var passwordAnimatedField: AnimatedField!
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var blobImageView: UIImageView!
    @IBOutlet weak var blobWidthConstraint: NSLayoutConstraint!
    
    func setUpElements() {
        
        blobWidthConstraint.constant = view.frame.width * 2/3
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        // Style email field
        var emailFormat = AnimatedFieldFormat()
        
        emailFormat.counterEnabled = false
        emailFormat.highlightColor = Constants.Theme.themeColor
        
        emailAnimatedField.type = .email
        emailAnimatedField.format = emailFormat
        emailAnimatedField.placeholder = "Email address"
        
        
        // Style password field
        var passwordFormat = AnimatedFieldFormat()
        
        passwordFormat.counterEnabled = false
        passwordFormat.highlightColor = Constants.Theme.themeColor
        
        passwordAnimatedField.type = .password(0, 100)
        passwordAnimatedField.format = passwordFormat
        passwordAnimatedField.placeholder = "Password"
        passwordAnimatedField.isSecure = true
        passwordAnimatedField.showVisibleButton = true
        
    }
    
    let child = SpinnerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
        if Auth.auth().currentUser != nil && Auth.auth().currentUser?.isEmailVerified == true {
            let context: LAContext = LAContext()
            context.localizedFallbackTitle = ""
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                
                switch context.biometryType {
                    
                case .faceID:
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Set your face to authenticate") { (good, error) in
                        if good {
                            
                            DispatchQueue.main.async {
                                
                                self.addChild(self.child)
                                self.child.view.frame = self.view.frame
                                self.view.addSubview(self.child.view)
                                self.child.didMove(toParent: self)
                                
                                self.performSegue(withIdentifier: "segueToHomeFromBiometrics", sender: self)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "segueToLoginViewController", sender: self)
                            }
                        }
                    }
                    
                case .touchID:
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Set your finger to authenticate") { (good, error) in
                        if good {
                            
                            DispatchQueue.main.async {
                                
                                self.addChild(self.child)
                                self.child.view.frame = self.view.frame
                                self.view.addSubview(self.child.view)
                                self.child.didMove(toParent: self)
                                
                                self.performSegue(withIdentifier: "segueToHomeFromBiometrics", sender: self)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "segueToLoginViewController", sender: self)
                            }
                        }
                    }
                    
                case .none:
                    break
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToLoginViewController", sender: self)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueToLoginViewController", sender: self)
            }
        }
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        do {
            self.child.willMove(toParent: nil)
            self.child.view.removeFromSuperview()
            self.child.removeFromParent()
        } catch {
            print("child spinner view was never intialized.")
        }
        
    }
    
}
