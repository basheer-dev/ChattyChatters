//
//  RegisterVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RegisterVC: UIViewController {
    let auth = FirebaseAuth.Auth.auth()
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    var profileImageSelected: Bool = false
    
    lazy var windowHeight = self.view.window!.windowScene!.screen.bounds.height
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemMint
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        imageView.layer.borderWidth = 1
        
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var nameField: UITextField = getField(named: "Name", isCapitalized: true)
    lazy var emailField: UITextField = getField(named: "Email")
    lazy var passwordField: UITextField = getField(named: "Password", isSecure: true)
    lazy var confirmPasswordField: UITextField = getField(named: "Confirm password", isSecure: true)
    
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
        field.returnKeyType = .next
        
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
    
    let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        let gesture = UIGestureRecognizer(target: self, action: #selector(configureProfilePicture))
        gesture.state = .began
        gesture.isEnabled = true
        profileImageView.addGestureRecognizer(gesture)
        
        emailField.keyboardType = .emailAddress
        confirmPasswordField.returnKeyType = .continue
        
        continueButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(continueButton)
        view.addSubview(imageActivityIndicator)
        view.addSubview(buttonActivityIndicator)
        
        configureLayouts()
    }
    
    
    // MARK: - ACTIONS
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
    
    @objc private func adjustViewForKeyboard(notification: Notification) {
        guard let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboard.cgRectValue        
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: 1) {
                if self.windowHeight > 900 {
                    self.profileImageView.transform = CGAffineTransform(translationX: 0, y: -40)
                } else if self.windowHeight < 700 {
                    self.profileImageView.transform = CGAffineTransform(translationX: 0, y: 50 - keyboardFrame.height)
                } else {
                    self.profileImageView.transform = CGAffineTransform(translationX: 0, y: 25 - keyboardFrame.height/2)
                }
                self.nameField.transform = CGAffineTransform(translationX: 0, y: Scale(windowHeight: self.windowHeight).getRegisterVCFieldsYForKeyboard() - keyboardFrame.height/2)
                self.emailField.transform = CGAffineTransform(translationX: 0, y: Scale(windowHeight: self.windowHeight).getRegisterVCFieldsYForKeyboard() - keyboardFrame.height/2)
                self.passwordField.transform = CGAffineTransform(translationX: 0, y: Scale(windowHeight: self.windowHeight).getRegisterVCFieldsYForKeyboard() - keyboardFrame.height/2)
                self.confirmPasswordField.transform = CGAffineTransform(translationX: 0, y: Scale(windowHeight: self.windowHeight).getRegisterVCFieldsYForKeyboard() - keyboardFrame.height/2)
                self.continueButton.transform = CGAffineTransform(translationX: 0, y: Scale(windowHeight: self.windowHeight).getRegisterVCButtonYForKeyboard() - keyboardFrame.height)
            }
        } else {
            UIView.animate(withDuration: 1) {
                self.profileImageView.transform = .identity
                self.nameField.transform = .identity
                self.emailField.transform = .identity
                self.passwordField.transform = .identity
                self.confirmPasswordField.transform = .identity
                self.continueButton.transform = .identity
            }
        }
    }
    
    @objc private func registerUser() {
        let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.text ?? ""
        let confirmedPassword = confirmPasswordField.text ?? ""
        
        if name.isEmpty {
            nameField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if email.isEmpty {
            emailField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        if password.isEmpty {
            passwordField.layer.borderColor = UIColor.systemRed.cgColor
            return
        }
        
        if password.count < 8 {
            passwordField.text = ""
            passwordField.placeholder = "Password is too short"
            passwordField.layer.borderColor = UIColor.systemRed.cgColor
            
            return
        }
        
        if password != confirmedPassword {
            confirmPasswordField.text = ""
            confirmPasswordField.placeholder = "Doesn't match"
            confirmPasswordField.layer.borderColor = UIColor.systemRed.cgColor
            
            return
        }
        
        // OK TO REGISTER USER
        disableViews()
        
        let userID = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
        
        auth.createUser(withEmail: email, password: password) {
            [weak self] _, error in
            guard error == nil,
                  let strongSelf = self else {
                let ac = UIAlertController(title: "Error", message: "An error has occurred while attempting to register your email. Please check your information, internet connection and try again!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                
                self?.enableViews()
                
                self?.present(ac, animated: true)
                return
            }
            
            strongSelf.database.child("users/\(userID)").setValue([
                "name": name,
                "hasProfilePicture": strongSelf.profileImageSelected
            ] as [String: Any] )
            
            if strongSelf.profileImageSelected {
                if let profileImageData = strongSelf.profileImageView.image?.jpegData(compressionQuality: 0.5) {
                    strongSelf.storage.child("profilesImages/\(userID).jpeg").putData(profileImageData) {
                        [weak self] _, error in
                        guard error == nil else {
                            self?.database.child("users/\(userID)").updateChildValues(["hasProfilePicture": false])
                            self?.enableViews()
                            return
                        }
                    }
                }
            }
            
            let userID = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
            UserDefaults.standard.set(userID, forKey: "userID")
            UserDefaults.standard.set(name, forKey: "userName")
            
            let destination = MainTabBar()
            destination.modalPresentationStyle = .fullScreen
            
            strongSelf.present(destination, animated: false)
        }
    }
    
    @objc private func configureProfilePicture() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "User Camera", style: .default, handler: {
            [weak self] _ in
            self?.pickImage(useCamera: true)
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {
            [weak self] _ in
            self?.pickImage()
        }))
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
            [weak self] _ in
            self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
            self?.profileImageSelected = false
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func pickImage(useCamera: Bool = false) {
        let imagePicker = UIImagePickerController()
        
        if useCamera {
            imagePicker.sourceType = .camera
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true)
    }
    
    private func disableViews() {
        imageActivityIndicator.startAnimating()
        buttonActivityIndicator.startAnimating()
        
        navigationItem.rightBarButtonItem?.tintColor = .systemGray4
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
        
        continueButton.configuration?.title = ""
        continueButton.configuration?.baseBackgroundColor = .systemGray4
        
        nameField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        emailField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        passwordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        confirmPasswordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)).cgColor
        
        nameField.textColor = .systemGray4
        emailField.textColor = .systemGray4
        passwordField.textColor = .systemGray4
        confirmPasswordField.textColor = .systemGray4
        
        profileImageView.isUserInteractionEnabled = false
        nameField.isUserInteractionEnabled = false
        emailField.isUserInteractionEnabled = false
        passwordField.isUserInteractionEnabled = false
        confirmPasswordField.isUserInteractionEnabled = false
        continueButton.isUserInteractionEnabled = false
    }
    
    private func enableViews() {
        imageActivityIndicator.stopAnimating()
        buttonActivityIndicator.stopAnimating()
        
        navigationItem.rightBarButtonItem?.tintColor = .systemMint
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
        
        continueButton.configuration?.title = "Continue"
        continueButton.configuration?.baseBackgroundColor = .systemMint
        
        nameField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        emailField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        passwordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        confirmPasswordField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        
        nameField.textColor = .systemMint
        emailField.textColor = .systemMint
        passwordField.textColor = .systemMint
        confirmPasswordField.textColor = .systemMint
        
        profileImageView.isUserInteractionEnabled = true
        nameField.isUserInteractionEnabled = true
        emailField.isUserInteractionEnabled = true
        passwordField.isUserInteractionEnabled = true
        confirmPasswordField.isUserInteractionEnabled = true
        continueButton.isUserInteractionEnabled = true
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Scale(windowHeight: windowHeight).getRegisterVCNameFieldTop()),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10),
            confirmPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            confirmPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Scale(windowHeight: windowHeight).getRegisterVCContinueButtonBottom()),
            continueButton.widthAnchor.constraint(equalToConstant: 150),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            buttonActivityIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            buttonActivityIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
        ])
    }
}


extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        profileImageView.image = pickedImage
        profileImageSelected = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


extension RegisterVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
            textField.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
            
            if textField == passwordField {
                textField.placeholder = "Password"
            }
            
            if textField == confirmPasswordField {
                textField.placeholder = "Confirm password"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            registerUser()
        }
        
        return false
    }
}
