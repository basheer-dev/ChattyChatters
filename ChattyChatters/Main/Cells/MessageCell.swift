//
//  MessageCell.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit

class MessageCell: UITableViewCell {
    let id = "MessageContainer"
    
    let container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 20
        
        return container
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var messageWasReceivedConstraint = contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
    lazy var messageWasSentConstraint = contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
    
    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(message: Message) {
        contentLabel.text = message.content
        
        if message.wasReceived {
            messageWasReceivedConstraint.isActive = true
            messageWasSentConstraint.isActive = false
            
            container.backgroundColor = .systemGray6
        } else {
            messageWasReceivedConstraint.isActive = false
            messageWasSentConstraint.isActive = true
            
            container.backgroundColor = .systemMint
            contentLabel.textColor = .systemBackground
        }
    }
    
    
    // MARK: - SUBVIEWS
    private func configureSubviews() {
        addSubview(container)
        addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10),
            container.bottomAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            container.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor, constant: -17),
            container.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: 17),
            
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            contentLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ])
    }
}
