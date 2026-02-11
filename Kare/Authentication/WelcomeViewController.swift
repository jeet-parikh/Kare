//
//  ViewController.swift
//  Kare
//
//  Created by Niraj Parikh on 3/21/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoImageView.alpha = 0
        self.animate()
    }
    
    private func animate() {
        
        UIView.animate(withDuration: 1, delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.logoImageView.alpha = 1.0
        }, completion: { (done) in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    self.performSegue(withIdentifier: "segueToBiometricsViewController", sender: self)
                })
            }
        })
    }
    
}

