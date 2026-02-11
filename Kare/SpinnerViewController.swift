//
//  SpinnerViewController.swift
//  Kare
//
//  Created by Jeet Parikh on 8/28/21.
//

import UIKit

class SpinnerViewController: UIViewController {

    var spinner = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.backgroundColor = .systemBackground.withAlphaComponent(0.85)
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 100).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 100).isActive = true
        spinner.layer.cornerRadius = 20
    }

}
