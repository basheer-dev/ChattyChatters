//
//  ChatVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseDatabase

class ChatVC: UIViewController {
    let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
    let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
    let database = Database.database().reference()
    let currentTimestamp = Int(NSDate().timeIntervalSince1970 * 1000)
    
    var messages: [Message] = []
    var messageReceiverID: String = ""
    var messageReceiverNickname: String = ""
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell().id)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset.top = 25
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    let container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.backgroundColor = .systemGray6
        
        return container
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.backgroundColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.4))
        textView.layer.cornerRadius = 15
        
        textView.contentInset.left = 10
        textView.contentInset.right = 10
        
        return textView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "paperplane.circle.fill")
        button.configuration?.baseForegroundColor = .systemMint
        
        return button
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        UserDefaults.standard.removeObject(forKey: "startNewChatWith")
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(container)
        view.addSubview(textView)
        view.addSubview(sendButton)
        
        configureLayouts()
    }
    
    func set(messageReceiverID: String, nickname: String = "", startNewChat: Bool = true) {
        self.messageReceiverID = messageReceiverID
        self.messageReceiverNickname = nickname
        title = nickname
        
        if startNewChat == false {
            database.child("chats/\(userID)/\(messageReceiverID)").updateChildValues(["newMessagesCount": 0] as [String: Int])
        }
    }
    
    
    // MARK: - ACTIONS
    @objc private func adjustViewForKeyboard(notification: Notification) {
        guard let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboard.cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height - tabBarController!.tabBar.frame.height, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
            
            if messages.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
            }
            
            UIView.animate(withDuration: 1) {
                self.container.transform = CGAffineTransform(translationX: 0, y: self.tabBarController!.tabBar.frame.height - keyboardFrame.height)
                self.textView.transform = CGAffineTransform(translationX: 0, y: self.tabBarController!.tabBar.frame.height - keyboardFrame.height)
                self.sendButton.transform = CGAffineTransform(translationX: 0, y: self.tabBarController!.tabBar.frame.height - keyboardFrame.height)
            }
        } else {
            tableView.contentInset = .zero
            
            UIView.animate(withDuration: 1) {
                self.container.transform = .identity
                self.textView.transform = .identity
                self.sendButton.transform = .identity
            }
        }
    }
    
    @objc private func sendMessage() {
        let messageToSend = textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)
        guard !messageToSend.isEmpty else { return }
        
        // THE MESSAGE IS READY TO SEND
        let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let time = String(format: "%02d:%02d", hour, minute)
        
        database.child("messages/\(userID)/\(messageReceiverID)").childByAutoId().setValue([
            "content": messageToSend,
            "time": time,
            "wasReceived": false,
            "timestamp": timestamp
        ] as [String: Any] )
        database.child("messages/\(messageReceiverID)/\(userID)").childByAutoId().setValue([
            "content": messageToSend,
            "time": time,
            "wasReceived": true,
            "timestamp": timestamp
        ] as [String: Any] )
        
        // CREATING NEW CHATS
        database.child("chats/\(userID)/\(messageReceiverID)").setValue([
            "nickname": messageReceiverNickname,
            "lastMessage": messageToSend,
            "time": time,
            "newMessagesCount": 0,
            "timestamp": timestamp
        ] as [String: Any] )
        database.child("chats/\(messageReceiverID)/\(userID)").getData {
            [weak self] error, snapshot in
            guard let strongSelf = self else { return }
            guard error == nil,
                  let chatInfo = snapshot?.value as? [String: Any] else {
                self?.database.child("chats/\(strongSelf.messageReceiverID)/\(strongSelf.userID)").setValue([
                    "nickname": strongSelf.userName,
                    "lastMessage": messageToSend,
                    "time": time,
                    "newMessagesCount": 1,
                    "timestamp": timestamp
                ] as [String: Any] )
                
                return
            }
            
            let count = chatInfo["newMessagesCount"] as? Int ?? 0
            self?.database.child("chats/\(strongSelf.messageReceiverID)/\(strongSelf.userID)").updateChildValues([
                "nickname": strongSelf.userName,
                "lastMessage": messageToSend,
                "time": time,
                "newMessagesCount": count + 1,
                "timestamp": timestamp
            ] as [String: Any] )
        }
        
        textView.text = ""
    }
    
    
    // MARK: - DATA
    private func fetchData() {
        database.child("messages/\(userID)/\(messageReceiverID)").queryOrdered(byChild: "timestamp").observe(.childAdded) {
            [weak self] snapshot in
            guard let newMessage = snapshot.value as? [String: Any],
                  let strongSelf = self else { return }
            
            self?.database.child("chats/\(strongSelf.userID)/\(strongSelf.messageReceiverID)").updateChildValues(["newMessagesCount": 0])

            self?.messages.append(
                Message(
                    content: newMessage["content"] as? String ?? "",
                    time: newMessage["time"] as? String ?? "",
                    wasReceived: newMessage["wasReceived"] as? Int ?? 0 == 1
                )
            )

            self?.tableView.insertRows(at: [IndexPath(row: strongSelf.messages.count - 1, section: 0)], with: .automatic)
            self?.tableView.scrollToRow(at: IndexPath(row: strongSelf.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -5),
            
            container.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}


extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell().id, for: indexPath) as? MessageCell else { fatalError() }
        cell.set(message: messages[indexPath.row])
        
        return cell
    }
}
