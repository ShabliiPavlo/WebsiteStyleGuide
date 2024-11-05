//
//  TryAgainViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class TryAgainViewController: UIViewController {
    
    @IBOutlet weak var alredyRegisterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
    }
    @IBAction func tryAgainPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupFonts() {
        alredyRegisterLabel.font = UIFont.nunitoSansRegular(.hiding)
    }
}
