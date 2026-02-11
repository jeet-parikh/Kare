//
//  ProfileViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/29/21.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import SCLAlertView
import SkeletonView

class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profilePictureWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePictureHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var profilePicTableViewCell: UITableViewCell!
    
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
        
        
        imagePicker.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        profilePictureWidthConstraint.constant = view.frame.width/2
        profilePictureHeightConstraint.constant = view.frame.width/2
        
        profilePictureImageView.layer.cornerRadius = view.frame.width/4
        
        profilePictureImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAlertController))
        
        profilePictureImageView.addGestureRecognizer(tapGesture)
        
        profilePicTableViewCell.showAnimatedSkeleton()
        
        findProfilePicture(email: Auth.auth().currentUser!.email!)
        
        populateNameAndEmail(from: Auth.auth().currentUser!.uid)
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toPasswordReset", sender: self)
    }
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        
        alert.addButton("Sign Out") {
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
                
                self.performSegue(withIdentifier: "signOutSegue", sender: self)
            } catch {
                SCLAlertView().showError("Error Signing Out", subTitle: "")
            }
        }
        
        alert.addButton("Cancel") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showWarning("Are you sure you want to sign out?", subTitle: "You will not longer recieve notifications for your items")
        
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false, showCircularIcon: false))
        
        alert.addButton("Delete Account") {
            if let user = Auth.auth().currentUser {
                
                let pwAlert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false, showCircularIcon: false))
                let txt = pwAlert.addTextField("Enter your password")
                txt.isSecureTextEntry = true
                pwAlert.addButton("Delete account") {
                    let userPassword = txt.text
                    let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: userPassword ?? "")
                    
                    user.reauthenticate(with: credential) { result, error in
                        if error != nil {
                            SCLAlertView().showError("Error deleting account", subTitle: "")
                            print(error?.localizedDescription)
                            print(error)
                        } else {
                            for listener in Constants.allSnapshotListeners {
                                listener.remove()
                            }
                            
                            let center = UNUserNotificationCenter.current()
                            
                            center.getPendingNotificationRequests { (notifications) in
                                print("REMOVING ALL NOTIFS")
                                for item in notifications {
                                    print("removing notifications")
                                    center.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                                }
                                
                            }
                            
                            let db = Firestore.firestore()
                            db.collection("users1").document(Auth.auth().currentUser!.uid).delete()
                            db.collection("friends").document(Auth.auth().currentUser!.uid).delete()
                            
                            let friendRef = db.collection("friends")
                            
                            friendRef.getDocuments { query, error in
                                var docIDS : [String] = []
                                
                                for document in query!.documents {
                                    docIDS.append(document.documentID)
                                }
                                
                                for userID in docIDS {
                                    friendRef.document(userID).updateData([
                                        "Followers": FieldValue.arrayRemove([Auth.auth().currentUser?.uid]),
                                        "Following": FieldValue.arrayRemove([Auth.auth().currentUser?.uid]),
                                        "Friend Requests": FieldValue.arrayRemove([Auth.auth().currentUser?.uid]),
                                        "Pending Friends": FieldValue.arrayRemove([Auth.auth().currentUser?.uid])
                                    ])
                                }
                                
                            }
                            
                            user.delete { error in
                                if let error = error {
                                    SCLAlertView().showError("Error deleting account", subTitle: "")
                                    print(error)
                                } else {
                                    self.performSegue(withIdentifier: "signOutSegue", sender: self)
                                }
                            }
                        }
                    }
                }
                
                pwAlert.addButton("Cancel") {
                    pwAlert.dismiss(animated: true, completion: nil)
                }
                
                pwAlert.showEdit("Verify your password", subTitle: "")
                
                
                
            }
            
        }
        
        alert.addButton("Cancel") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showError("Are you sure you want to delete this account?", subTitle: "Once deleted, previous data cannot be recovered.")
        
    }
    
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        openAlertController()
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let db = Firestore.firestore()
        let docRef = db.collection("users1").document(Auth.auth().currentUser!.uid)
        
        if textField.tag == 1 {
            // First Name text field
            docRef.setData([
                "First Name": firstNameTextField.text
            ], merge: true)
            
        } else if textField.tag == 2 {
            // Last Name Text Field
            docRef.setData([
                "Last Name": lastNameTextField.text
            ], merge: true)
        }
        
    }
    
    @objc func openAlertController() {
        print("openAlertController")
        
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false, showCircularIcon: false))
        
        alert.addButton("Camera") {
            self.openCamera()
        }
        alert.addButton("Photo Gallery") {
            self.openGallery()
        }
        alert.addButton("Cancel") {
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.showNotice("Choose an image", subTitle: "")
    }
    
    var profilePicture: UIImage = UIImage(named: "defaultProfilePicture")! {
        didSet {
            
            let image = profilePicture
            
            profilePictureImageView.image = image
            profilePicTableViewCell.hideSkeleton()
            
            // Store image data
            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                return
            }
            
            let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
            let storageProfileRef = storageRef.child("profile").child(Auth.auth().currentUser!.email!)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata) { (storageMetaData, error) in
                if error != nil {
                    print("storing profile pic")
                    print(error?.localizedDescription)
                    return
                }
                
                storageProfileRef.downloadURL { (url, error) in
                    if let metaImageUrl = url?.absoluteString {
                        if let currentUser = Auth.auth().currentUser {
                            Firestore.firestore().collection("users1").document(currentUser.uid).setData(["Profile Image URL":metaImageUrl], merge: true)
                        }
                    }
                }
            }
        }
    }
    
    func findProfilePicture(email: String) {
        let storageRef = Storage.storage().reference(forURL: "gs://prokare-c4b3c.appspot.com/")
        let storageProfileRef = storageRef.child("profile").child(email)
        
        storageProfileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if error == nil {
                self.profilePicture = UIImage(data: data!)!
            } else {
                self.profilePicture = UIImage(named: "defaultProfilePicture")!
            }
        }
    }
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    func populateNameAndEmail(from uid: String) {
        
        let db = Firestore.firestore()
        let docRef = db.collection("users1").document(uid)
        
        docRef.getDocument { document, error in
            if error != nil {
                print("ERROR FETCHING USER DATA - USERS1")
                print(error)
            } else {
                self.firstNameTextField.text = document?.data()!["First Name"] as? String
                self.lastNameTextField.text = document?.data()!["Last Name"] as? String
                self.emailTextField.text = document?.data()!["Email"] as? String
            }
        }
        
    }
    
    //MARK: - Image Picker
    
    let imagePicker = UIImagePickerController()
    var image: UIImage?
    
    func openCamera(){
        
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            profilePicture = userPickedImage
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toPasswordReset":
            let vc = segue.destination as! PasswordResetViewController
            vc.emailPreFill = emailTextField.text ?? ""
        default:
            break
        }
    }
    
}
