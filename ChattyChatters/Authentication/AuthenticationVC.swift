//
//  AuthenticationVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit

class AuthenticationVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AuthenticationWindow"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .filled()
        button.configuration?.title = "Login"
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.baseBackgroundColor = .systemMint
        
        return button
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .tinted()
        button.configuration?.title = "Register"
        button.configuration?.baseForegroundColor = .systemMint
        button.configuration?.baseBackgroundColor = .systemMint
        
        return button
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(showLoginWindow), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(showRegisterWindow), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        configureLayouts()
    }
    
    
    // MARK: - ACTIONS
    @objc private func showLoginWindow() {
        let destination = UINavigationController(rootViewController: LoginVC())
        
        present(destination, animated: true)
    }
    
    @objc private func showRegisterWindow() {
        let destination = UINavigationController(rootViewController: RegisterVC())
        
        present(destination, animated: true)
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            loginButton.widthAnchor.constraint(equalToConstant: 150),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant: 150),
            registerButton.heightAnchor.constraint(equalToConstant: 44),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
