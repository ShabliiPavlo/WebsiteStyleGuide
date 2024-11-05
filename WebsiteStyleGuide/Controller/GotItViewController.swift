//
//  GotItViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class GotItViewController: UIViewController {
    
    @IBOutlet weak var gotItLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
    }
    @IBAction func gotItPress(_ sender: Any) {
        if let tabBarController = self.presentingViewController as? UITabBarController {
            self.dismiss(animated: true) {
                tabBarController.selectedIndex = 0
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func setupFonts() {
        gotItLabel.font = UIFont.nunitoSansRegular(.hiding)
    }
}
