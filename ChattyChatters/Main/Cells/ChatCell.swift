//
//  ChatCell.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ChatCell: UITableViewCell {
    let id = "CellContainer"
    
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        
        return label
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        
        return label
    }()
    
    let newMessagesCount: UILabel =  {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        
        return label
    }()
    
    let countContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.backgroundColor = UIColor(cgColor: CGColor(red: 0.15, green: 0.76, blue: 0.74, alpha: 1))
        container.layer.cornerRadius = 12
        
        return container
    }()
    
    let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(chat: Chat) {
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        userNameLabel.text = ""
        timeLabel.text = ""
        lastMessageLabel.text = ""
        newMessagesCount.text = ""
        
        userNameLabel.text = chat.nickname
        timeLabel.text = chat.time
        lastMessageLabel.text = chat.lastMessage
        newMessagesCount.text = String(chat.newMessagesCount)
        
        if chat.newMessagesCount > 0 {
            countContainer.isHidden = false
            newMessagesCount.isHidden = false
            
            lastMessageLabel.textColor = .systemMint
        } else {
            countContainer.isHidden = true
            newMessagesCount.isHidden = true
            
            lastMessageLabel.textColor = .systemGray
        }
        
        database.child("users/\(chat.userID)").getData {
            [weak self] error, snapshot in
            guard error == nil,
                  let userInfo = snapshot?.value as? [String: Any] else { return }
            
            if userInfo["hasProfilePicture"] as? Int ?? 0 == 1 {
                self?.imageActivityIndicator.startAnimating()
                
                self?.storage.child("profilesImages/\(chat.userID).jpeg").downloadURL {
                    url, error in
                    guard error == nil,
                          let url = url else { return }
                    
                    URLSession.shared.dataTask(with: url) {
                        data, _, error in
                        guard error == nil,
                              let data = data else { return }
                        
                        DispatchQueue.main.async {
                            self?.imageActivityIndicator.stopAnimating()
                            self?.profileImageView.image = UIImage(data: data)
                        }
                    }.resume()
                }
            } else {
                self?.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                self?.profileImageView.tintColor = .systemMint
            }
        }
    }
    
    
    // MARK: - SUBVIEWS CONFIG
    private func configureSubviews() {
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(userNameLabel)
        addSubview(lastMessageLabel)
        addSubview(countContainer)
        addSubview(newMessagesCount)
        addSubview(imageActivityIndicator)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            userNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            timeLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            lastMessageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            lastMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            
            countContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            countContainer.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),

            countContainer.heightAnchor.constraint(equalTo: newMessagesCount.heightAnchor, constant: 10),
            countContainer.widthAnchor.constraint(equalTo: countContainer.heightAnchor),
            
            newMessagesCount.centerXAnchor.constraint(equalTo: countContainer.centerXAnchor),
            newMessagesCount.centerYAnchor.constraint(equalTo: countContainer.centerYAnchor),
            
            imageActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            
        ])
    }
}
