//
//  UserCell.swift
//  FireChat
//
//  Created by 藤門莉生 on 2021/09/12.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {
    // Mark: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    private let profileImageView: UIImageView =  {
        let iv = UIImageView()
        iv.backgroundColor = .systemPurple
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Super man"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Rio Fujimon"
        return label
    }()
    
    // Mark: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDeimensions(height: 56, width: 56)
        profileImageView.layer.cornerRadius = 56/2
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Mark: - Helpers
    func configure() {
        guard let user = user else { return }
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
        
        guard let url = URL(string: user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url)
    }
}

