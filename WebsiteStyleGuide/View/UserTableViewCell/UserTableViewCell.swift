//
//  UserTableViewCell.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        positionLabel.text = user.position
        emailLabel.text = user.email
        phoneLabel.text = user.phone
        
        if let url = URL(string: user.photo) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data)
                    }
                }
            }
            .resume()
        }
    }
}

extension UserTableViewCell {
    func setupUI() {
        userImageView.layer.cornerRadius = 25
        userImageView.clipsToBounds = true
    }
}
