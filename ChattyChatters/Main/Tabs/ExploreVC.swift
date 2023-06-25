//
//  ExploreVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseDatabase

class ExploreVC: UIViewController {
    let database = Database.database().reference()
    var posts: [Post] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell().id)
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.top = 25
        tableView.contentInset.bottom = 200
        
        return tableView
    }()
    
    let addPostButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis.rtl"), for: .normal)
        button.tintColor = .systemBackground
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 25
        
        return button
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Explore"
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        addPostButton.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(addPostButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addPostButton.widthAnchor.constraint(equalToConstant: 50),
            addPostButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    // MARK: - ACTIONS
    @objc private func createNewPost() {
        let destination = UINavigationController(rootViewController: NewPostVC())
        present(destination, animated: true)
    }
    
    
    // MARK: - DATA
    private func fetchData() {
        database.child("posts").queryOrdered(byChild: "timestamp").observe(.childAdded) {
            [weak self] snapshot in
            guard let post = snapshot.value as? [String: Any],
                  let _ = self else { return }
            
            let postID = snapshot.key
            self?.posts.append(
                Post(
                    postID: postID,
                    userID: post["userID"] as? String ?? "",
                    date: post["date"] as? String ?? "",
                    time: post["time"] as? String ?? "",
                    content: post["content"] as? String ?? "",
                    hasImage: post["hasImage"] as? Int ?? 0 == 1,
                    likesCount: post["likesCount"] as? Int ?? 0,
                    commentsCount: post["commentsCount"] as? Int ?? 0
                )
            )
            
            self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//            self?.tableView.insertRows(at: [IndexPath(row: strongSelf.posts.count - 1, section: 0)], with: .automatic)
        }
    }
}


extension ExploreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell().id, for: indexPath) as? PostCell else { fatalError() }
        cell.set(post: posts.reversed()[indexPath.row])
                
        return cell
    }
}
