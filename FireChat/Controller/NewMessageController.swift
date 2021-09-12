//
//  NewMessageController.swift
//  FireChat
//
//  Created by 藤門莉生 on 2021/09/12.
//

import UIKit

private let reuseIdentifier = "UserCell"

class NewMessageController: UITableViewController {
    
    // Mark - Propertites
    
    private var users = [User]()
    
    // Mark - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    // Mark: - Selector
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    // Mark: - API
    func fetchUsers() {
        Service.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    
    // Mark - Helpers
    func configureUI() {
        configureNavigationBar(withTitle: "New Message", prefersLargeTitles: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        
    }
    
    
}

// Mark: - UITableViewDataSource
extension NewMessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        
        print("Debug: Index row is \(indexPath.row)")
        print("Debug: User in array is \(users[indexPath.row])")
        return cell
    }
}


