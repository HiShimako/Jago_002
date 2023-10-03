//
//  TutorialViewController.swift
//  Jago_002
//
//  Created by user on 2023/10/02.
//

import UIKit

class TutorialViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "LOGO")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
}
