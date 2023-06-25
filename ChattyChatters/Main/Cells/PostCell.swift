//
//  PostCell.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 21/06/2023.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PostCell: UITableViewCell {
    let id = "PostContainer"
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemGray4
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let configButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .systemMint
        
        return button
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading ..."
        
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        
        return label
    }()
    
    let contentLabel: UILabel = {
        let content = UILabel()
        content.translatesAutoresizingMaskIntoConstraints = false

        content.numberOfLines = 0
        content.font = .systemFont(ofSize: 14)
        
        return content
    }()
    
    let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemMint
        
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .systemMint
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    let starButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemMint
        
        return button
    }()
    
    let likesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        
        return label
    }()
    
    let commentsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        
        return label
    }()
    
    let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    let profileImageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    lazy var hasImageConstraints = likeButton.topAnchor.constraint(equalTo: contentImageView.bottomAnchor, constant: 10)
    lazy var noImageConstraints = likeButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10)
    
    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(post: Post) {
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        userNameLabel.text = ""
        dateLabel.text = ""
        timeLabel.text = ""
        contentImageView.image = .none
        likesCountLabel.text = ""
        commentsCountLabel.text = ""
        
        dateLabel.text = post.date
        timeLabel.text = post.time
        likesCountLabel.text = String(post.likesCount)
        commentsCountLabel.text = String(post.commentsCount)
        
        // Content
        contentLabel.text = post.content
        
        // Getting the userName and image of the user
        database.child("users/\(post.userID)").getData {
            [weak self] error, snapshot in
            guard error == nil,
                  let userInfo = snapshot?.value as? [String: Any] else { return }
            self?.userNameLabel.text = userInfo["name"] as? String ?? "Unknown"
            
            if userInfo["hasProfilePicture"] as? Int ?? 0 == 1 {
                self?.profileImageActivityIndicator.startAnimating()
                self?.storage.child("profilesImages/\(post.userID).jpeg").downloadURL(completion: {
                    url, error in
                    guard error == nil,
                          let url = url else { return }
                    
                    URLSession.shared.dataTask(with: url) {
                        data, _, error in
                        guard error == nil,
                              let data = data else { return }
                        
                        DispatchQueue.main.async {
                            self?.profileImageActivityIndicator.stopAnimating()
                            self?.profileImageView.image = UIImage(data: data)
                        }
                    }.resume()
                })
            } else {
                self?.profileImageView.tintColor = .systemMint
            }
        }
        
        // Getting the post's image
        if post.hasImage {
            contentImageView.isHidden = false
            
            hasImageConstraints.isActive = true
            noImageConstraints.isActive = false
            
            // Fetching the image from the database
            imageActivityIndicator.startAnimating()
            fetchImage(postID: post.postID)
        } else {
            contentImageView.isHidden = true
            
            hasImageConstraints.isActive = false
            noImageConstraints.isActive = true
        }
    }
    
    private func fetchImage(postID: String) {
        storage.child("posts/\(postID).jpeg").downloadURL {
            url, error in
            guard error == nil,
                  let url = url else {
                self.fetchImage(postID: postID)
                return
            }
            
            URLSession.shared.dataTask(with: url) {
                [weak self] data, _, error in
                guard error == nil,
                      let data = data else {
                    self?.fetchImage(postID: postID)
                    return
                }
                
                DispatchQueue.main.async {
                    self?.imageActivityIndicator.stopAnimating()
                    self?.contentImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
    
    
    // MARK: - SUBVIEWS
    private func configureSubviews() {
        addSubview(profileImageView)
        addSubview(configButton)
        addSubview(userNameLabel)
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(contentLabel)
        addSubview(contentImageView)
        addSubview(likeButton)
        addSubview(likesCountLabel)
        addSubview(commentButton)
        addSubview(commentsCountLabel)
        addSubview(starButton)
        
        addSubview(imageActivityIndicator)
        addSubview(profileImageActivityIndicator)
        
        configureLayouts()
    }
    
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            configButton.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            configButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            userNameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -5),
            
            dateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: configButton.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            contentImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            contentImageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            contentImageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            contentImageView.heightAnchor.constraint(equalToConstant: 150),
            
//            likeButton.topAnchor.constraint(equalTo: contentImageView.bottomAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            likesCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor),
            likesCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            commentButton.topAnchor.constraint(equalTo: likeButton.topAnchor),
            commentButton.centerXAnchor.constraint(equalTo: contentLabel.centerXAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 30),
            commentButton.heightAnchor.constraint(equalToConstant: 30),
            
            commentsCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor),
            commentsCountLabel.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
            
            starButton.topAnchor.constraint(equalTo: likeButton.topAnchor),
            starButton.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            starButton.widthAnchor.constraint(equalToConstant: 30),
            starButton.heightAnchor.constraint(equalToConstant: 30),
            
            imageActivityIndicator.centerXAnchor.constraint(equalTo: contentImageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: contentImageView.centerYAnchor),
            
            profileImageActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            profileImageActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            
        ])
    }
}
