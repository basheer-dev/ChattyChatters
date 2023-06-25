//
//  MainTabBar.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit

class MainTabBar: UITabBarController {
    let userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        UITabBar.appearance().tintColor = .systemMint
        
        let explore = UINavigationController(rootViewController: ExploreVC())
        let notifications = UINavigationController(rootViewController: NotificationsVC())
        let chats = UINavigationController(rootViewController: ChatsVC())
        let profile = UINavigationController(rootViewController: ProfileVC())
        
        explore.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari.fill"), tag: 0)
        notifications.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell.fill"), tag: 1)
        chats.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message.fill"), tag: 2)
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 3)
        
        viewControllers = [explore, notifications, chats, profile]
        selectedIndex = 2
    }
}
