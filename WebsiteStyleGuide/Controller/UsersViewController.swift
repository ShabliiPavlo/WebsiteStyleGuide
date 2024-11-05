//
//  ViewController.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

import UIKit

class UsersViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nouserImage: UIImageView!
    @IBOutlet weak var noUserLebel: UILabel!
    
    // MARK: - Properties
    
    var users: [User] = []
    var currentPage = 1
    var isLoading = false
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts() 
        setupTableView()
        fetchUsers(page: currentPage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetData()
        fetchUsers(page: currentPage)
    }
    
    // MARK: - Data Handling
    
    private func fetchUsers(page: Int) {
        isLoading = true
        NetworkManager.shared.fetchUsers(page: page) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let usersResponse):
                if usersResponse.users.isEmpty {
                    self.showEmptyState()
                } else {
                    self.users.append(contentsOf: usersResponse.users)
                    self.showTableView()
                }
            case .failure(let error):
                print("Ошибка при загрузке пользователей: \(error.localizedDescription)")
            }
        }
    }
    
    private func resetData() {
        users.removeAll()
        currentPage = 1
        tableView.reloadData()
    }
    
    // MARK: - UI State Methods
    
    private func showEmptyState() {
        tableView.isHidden = true
        nouserImage.isHidden = false
        noUserLebel.isHidden = false
    }
    
    private func showTableView() {
        tableView.isHidden = false
        nouserImage.isHidden = true
        noUserLebel.isHidden = true
        tableView.reloadData()
    }
    
    private func setupFonts() {
        noUserLebel.font = UIFont.nunitoSansRegular(.hiding)
    }

    // MARK: - User Management
    
    func addUser(_ newUser: User) {
        users.append(newUser)
        tableView.reloadData()
    }
}

// MARK: - UITableView Setup

extension UsersViewController {
    
    private func setupTableView() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension UsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UsersViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        
        if position > (contentHeight - scrollView.frame.size.height - 100) && !isLoading {
            currentPage += 1
            fetchUsers(page: currentPage)
        }
    }
}
