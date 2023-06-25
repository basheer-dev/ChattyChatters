//
//  UserCell.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseStorage

class UserCell: UITableViewCell {
    let id = "UserContainer"
    let storage = Storage.storage().reference()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
        imageView.tintColor = .systemMint
        
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: User) {
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        userNameLabel.text = ""
        
        userNameLabel.text = user.userName
        
        if user.hasProfile {
            storage.child("profilesImages/\(user.userID).jpeg").downloadURL {
                url, error in
                guard error == nil,
                      let url = url else { return }
                
                URLSession.shared.dataTask(with: url) {
                    [weak self] data, _, error in
                    guard error == nil,
                          let data = data else { return }
                    DispatchQueue.main.async {
                        self?.profileImageView.image = UIImage(data: data)
                    }
                }.resume()
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
    
    
    // MARK: - SUBVIEWS
    private func configureSubviews() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
