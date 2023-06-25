//
//  LoginVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController {
    let auth = Auth.auth()
    let database = Database.database().reference()
    
    lazy var emailField: UITextField = getField(named: "Email")
    lazy var passwordField: UITextField = getField(named: "Password", isSecure: true)
    
    let continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .filled()
        button.configuration?.title = "Continue"
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.baseBackgroundColor = .systemMint
        
        return button
    }()
    
    private func getField(named name: String, isCapitalized: Bool = false, isSecure: Bool = false) -> UITextField {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        
        field.placeholder = name
        field.textColor = .systemMint
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 10
        
        field.delegate = self
        
        field.leftViewMode = .always
        field.rightViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        
        if isSecure {
            field.isSecureTextEntry = true
        }
        
        if isCapitalized {
            field.autocapitalizationType = .words
        }
        
        return field
    }
    
    let buttonActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = .systemMint
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        emailField.keyboardType = .emailAddress
        emailField.returnKeyType = .next
        passwordField.returnKeyType = .continue
        
        continueButton.addTarget(self, action: #selector(logUser), for: .touchUpInside)
        
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(continueButton)
        view.addSubview(buttonActivityIndicator)
        
        configureLayouts()
    }
    
    
    // MARK: - ACTIONS
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    @objc private func logUser() {
        let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.text ?? ""
        
        if email.isEmpty {
            emailField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if password.isEmpty {
            passwordField.layer.borderColor = UIColor.systemRed.cgColor
            
            return
        }
        
        disableViews()
        // OK TO LOG IN
        auth.signIn(withEmail: email, password: password) {
            [weak self] _, error in
            guard error == nil else {
                let ac = UIAlertController(title: "Error", message: "An error has occurred while attempting to sign in. Please check you information, internet connection and try again!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.present(ac, animated: true)
                
                self?.enableViews()
                
                return
            }
            let userID = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
            UserDefaults.standard.set(userID, forKey: "userID")
            
            self?.database.child("users/\(userID)").getData {
                error, snapshot in
                guard error == nil,
                      let values = snapshot?.value as? [String: Any] else {
                    UserDefaults.standard.set("", forKey: "userName")
                    
                    self?.enableViews()
                    return
                }
                UserDefaults.standard.set(values["name"], forKey: "userName")
            }
            
            let destination = MainTabBar()
            destination.modalPresentationStyle = .fullScreen
            
            self?.present(destination, animated: false)
        }
    }
    
    private func disableViews() {
        buttonActivityIndicator.startAnimating()
        continueButton.configuration?.title = ""
        continueButton.configuration?.baseBackgroundColor = .systemGray4
        emailField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        passwordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        emailField.textColor = .systemGray4
        passwordField.textColor = .systemGray4
        
        emailField.isUserInteractionEnabled = false
        passwordField.isUserInteractionEnabled = false
        continueButton.isUserInteractionEnabled = false
    }
    
    private func enableViews() {
        buttonActivityIndicator.stopAnimating()
        continueButton.configuration?.title = "Continue"
        continueButton.configuration?.baseBackgroundColor = .systemMint
        emailField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        passwordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        emailField.textColor = .systemMint
        passwordField.textColor = .systemMint
        
        emailField.isUserInteractionEnabled = true
        passwordField.isUserInteractionEnabled = true
        continueButton.isUserInteractionEnabled = true
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 50),
            continueButton.widthAnchor.constraint(equalToConstant: 150),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonActivityIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            buttonActivityIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
}


extension LoginVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
            textField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            logUser()
        }
        
        return false
    }
}
