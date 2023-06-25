//
//  NotificationsVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 21/06/2023.
//

import UIKit

class NotificationsVC: UIViewController {
    let notifications: [NotificationObject] = [
        NotificationObject(userName: "Mohamed Abdulmalik", content: "commented \"منور\" on your post.", seen: false),
        NotificationObject(userName: "Salah Alnoor", content: "liked your post."),
        NotificationObject(userName: "Mohamed Khalid", content: "commented \"جلا\" on your post"),
        NotificationObject(userName: "Dr. Anwar Alsadat Hamad", content: "commented \"😂😂😂😂😂😂\" on your post.", seen: false),
        NotificationObject(userName: "Basheer Abdulmalik", content: "liked your post.", seen: false),
        NotificationObject(userName: "Hozaifa Talib", content: "liked your post."),
        NotificationObject(userName: "Hamid Awad", content: "commented \"not again with those pink jokes 😂, aight we get it\" on your post.", seen: false),
        NotificationObject(userName: "Basheer Abdulmalik", content: "liked your post."),
        NotificationObject(userName: "Moniem Husam", content: "liked your post."),
        NotificationObject(userName: "Mohamed Khalid", content: "liked your post.", seen: false),
        NotificationObject(userName: "Albarra Sami", content: "commented \"التمرين الساعة ٤م\" on your post."),
        NotificationObject(userName: "Hozaifa Talib", content: "liked your post."),
        NotificationObject(userName: "Dr. Anwar Alsadat Hamad", content: "liked your post."),
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell().id)
        tableView.contentInset.top = 25
        
        return tableView
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Notifications"
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        
        view.addSubview(tableView)
    }
}


extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell().id, for: indexPath) as? NotificationCell else { fatalError() }
        cell.set(notification: notifications[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
