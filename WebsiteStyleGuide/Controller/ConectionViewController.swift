//
//  ConectionViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class ConectionViewController: UIViewController {
    
    @IBOutlet weak var noConnectLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NetworkManager.shared.checkConnection { [weak self] isConnected in
            if isConnected {
                self?.openUsersViewController()
            }
        }
    }

    @IBAction func tryAgaineButtonPress(_ sender: Any) {
        NetworkManager.shared.checkConnection { [weak self] isConnected in
            if isConnected {
                self?.openUsersViewController()
            } else {
                print("No connection")
            }
        }
    }
    
    func openUsersViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let usersVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            usersVC.modalPresentationStyle = .fullScreen
            self.present(usersVC, animated: true, completion: nil)
        }
    }
}

extension ConectionViewController {
  func setupUI() {
      noConnectLabel.font = UIFont.nunitoSansRegular(.hiding)
    }
}
