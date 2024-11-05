//
//  TryAgainViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class TryAgainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tryAgainPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
