//
//  NotificationCell.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 22/06/2023.
//

import UIKit

class NotificationCell: UITableViewCell {
    let id = "NotificationContainer"
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 2
        label.textColor = .systemMint
        label.font = .systemFont(ofSize: 14)
        
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .systemMint
        
        return button
    }()
    
    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(notification: NotificationObject) {
        profileImageView.image = UIImage(named: notification.userName)
        contentLabel.text = notification.userName + " " + notification.content
        
        if notification.seen {
            contentLabel.textColor = .systemGray
        }
    }
    
    
    // MARK: - SUBVIEWS
    private func configureSubviews() {
        addSubview(profileImageView)
        addSubview(contentLabel)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            contentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            contentLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -10),
            
            actionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            actionButton.widthAnchor.constraint(equalToConstant: 20),
            actionButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
