//
//  NewChatVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseDatabase

class NewChatVC: UIViewController {
    let database = Database.database().reference()
    let userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    var users: [User] = []
    var usersCopy: [User] = []
    
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
        
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 60
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell().id)
        
        return tableView
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemMint
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        navigationItem.searchController = searchController
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "startNewChatWith") == nil {
            UserDefaults.standard.set("Cancel", forKey: "startNewChatWith")
        }
    }
    
    
    // MARK: - ACTIONS
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    
    // MARK: - DATA
    private func fetchData() {
        database.child("users").queryOrdered(byChild: "name").observe(.childAdded) {
            [weak self] snapshot in
            guard let user = snapshot.value as? [String: Any],
                  let strongSelf = self else { return }
            
            if snapshot.key != strongSelf.userID {
                self?.users.append(
                    User(
                        userID: snapshot.key,
                        userName: user["name"] as? String ?? "",
                        hasProfile: user["hasProfilePicture"] as? Int ?? 0 == 1
                    )
                )
                
                self?.usersCopy = strongSelf.users
                self?.tableView.insertRows(at: [IndexPath(row: strongSelf.users.count - 1, section: 0)], with: .automatic)
            }
        }
    }
}


extension NewChatVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        users = usersCopy
        let userToFind = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        
        if !userToFind.isEmpty {
            users = users.filter({ $0.userName.lowercased().contains(userToFind) })
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        users = usersCopy
        tableView.reloadData()
    }
}


extension NewChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell().id, for: indexPath) as? UserCell else { fatalError() }
        cell.set(user: users[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(users[indexPath.row].userID, forKey: "startNewChatWith")
        
        dismiss(animated: true)
    }
}
