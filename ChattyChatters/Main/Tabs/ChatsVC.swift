//
//  ChatsVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseDatabase

class ChatsVC: UIViewController {
    let database = Database.database().reference()
    let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
    var chats: [Chat] = []
    var chatsCopy: [Chat] = []
    var newMessagesCount: Int = 0
    
    var timer: Timer!
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        
        controller.searchBar.autocorrectionType = .no
        controller.searchBar.autocapitalizationType = .none
        
        return controller
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell().id)
        tableView.rowHeight = 60
        
        return tableView
    }()
        
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemMint
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewChat))
        title = "Chats"
                
        fetchData()
        observeChanges()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        
        view.addSubview(tableView)
    }
    
    
    // MARK: - ACTIONS
    @objc private func addNewChat() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkForSelectedNewUser), userInfo: nil, repeats: true)
        let destination = UINavigationController(rootViewController: NewChatVC())
        
        present(destination, animated: true)
    }
    
    @objc private func checkForSelectedNewUser() {
        guard let newUserID = UserDefaults.standard.string(forKey: "startNewChatWith") else { return }
        UserDefaults.standard.removeObject(forKey: "startNewChatWith")
        
        if newUserID != "Cancel" {
            let destination = ChatVC()
            var startNewChat = true
            
            if chats.contains(where: { $0.userID == newUserID }) {
                startNewChat = false
            }
            
            database.child("users/\(newUserID)").getData {
                [weak self] error, snapshot in
                guard error == nil,
                      let info = snapshot?.value as? [String: Any] else { return }
                
                destination.set(messageReceiverID: newUserID, nickname: info["name"] as? String ?? "", startNewChat: startNewChat)
                self?.navigationController?.pushViewController(destination, animated: true)
            }
        }
        
        timer.invalidate()
    }
    
    
    // MARK: - DATA
    private func fetchData() {
        database.child("chats/\(userID)").queryOrdered(byChild: "timestamp").observe(.childAdded) {
            [weak self] snapshot in
            guard let chat = snapshot.value as? [String: Any],
                    let strongSelf = self else { return }
            let userID = snapshot.key
            
            self?.chats.append(
                Chat(
                    with: userID,
                    nickname: chat["nickname"] as? String ?? "",
                    lastMessage: chat["lastMessage"] as? String ?? "",
                    newMessagesCount: chat["newMessagesCount"] as? Int ?? 0,
                    time: chat["time"] as? String ?? ""
                )
            )
            self?.chatsCopy = strongSelf.chats
            
            self?.newMessagesCount += chat["newMessagesCount"] as? Int ?? 0
            
            if let tabBarItems = strongSelf.tabBarController?.tabBar.items {
                tabBarItems[2].badgeValue = strongSelf.newMessagesCount > 0 ? String(strongSelf.newMessagesCount): nil
            }
            
            self?.tableView.reloadData()
        }
    }
    
    private func observeChanges() {
        database.child("chats/\(userID)").observe(.childChanged) {
            [weak self] snapshot in
            guard let chat = snapshot.value as? [String: Any],
                  let strongSelf = self else { return }
            let updatedChat = Chat(
                with: snapshot.key,
                nickname: chat["nickname"] as? String ?? "",
                lastMessage: chat["lastMessage"] as? String ?? "",
                newMessagesCount: chat["newMessagesCount"] as? Int ?? 0,
                time: chat["time"] as? String ?? ""
            )
            
            let updateIndex = (self?.chats.firstIndex(where: { $0.userID == updatedChat.userID}))! as Int
            let newMessagesCountForResetedChat = strongSelf.chats[updateIndex].newMessagesCount
            
            self?.chats.removeAll(where: { $0.userID == updatedChat.userID })
            
            if chat["newMessagesCount"] as? Int ?? 0 > 0{
                // A new message was added
                self?.chats.append(updatedChat)
                self?.newMessagesCount += 1
            } else {
                // Messages counter was reseted
                self?.chats.insert(updatedChat, at: updateIndex)
                self?.newMessagesCount -= newMessagesCountForResetedChat
            }
            self?.chatsCopy = strongSelf.chats
            
            if let tabBarItems = strongSelf.tabBarController?.tabBar.items {
                tabBarItems[2].badgeValue = strongSelf.newMessagesCount > 0 ? String(strongSelf.newMessagesCount): nil
            }
            self?.tableView.reloadData()
        }
    }

}


extension ChatsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        chats = chatsCopy
        let chatToFind = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        if !chatToFind.isEmpty {
            chats = chats.filter({ $0.nickname.lowercased().contains(chatToFind) })
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        chats = chatsCopy
        tableView.reloadData()
    }
}


extension ChatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell().id, for: indexPath) as? ChatCell else { fatalError() }
        cell.set(chat: chats.reversed()[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destination = ChatVC()
        destination.set(messageReceiverID: chats.reversed()[indexPath.row].userID, nickname: chats.reversed()[indexPath.row].nickname, startNewChat: false)
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            database.child("chats/\(userID)/\(chats[indexPath.row].userID)").removeValue()
            database.child(("messages/\(userID)/\(chats[indexPath.row].userID)")).removeValue()
            
            chats.remove(at: indexPath.row)
            chatsCopy = chats
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
