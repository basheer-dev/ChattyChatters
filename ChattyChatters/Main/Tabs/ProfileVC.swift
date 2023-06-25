//
//  ProfileVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 19/06/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileVC: UIViewController {
    let auth = Auth.auth()
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    var timer: Timer!
    var profileImageSelected: Bool = false
    let settings = ["Saved Messages", "Posts", "Privacy", "Notifications", "Storage", "Contact Us", "Help"]
    let settingsImages = ["star.square.on.square.fill", "square.and.pencil.circle.fill", "hand.raised.circle.fill", "bell.circle.fill", "memorychip.fill", "phone.circle.fill", "questionmark.circle.fill"]
    var isEditingUserInfo: Bool = false
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2))
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)).cgColor
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let nameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        
        field.placeholder = "Enter your name"
        field.text = "Loading "
        field.textAlignment = .center
        field.font = .systemFont(ofSize: 18, weight: .bold)
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.isUserInteractionEnabled = false
        
        return field
    }()
    
    let EditedProfileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemMint
        imageView.backgroundColor = .systemBackground
        imageView.layer.borderColor = UIColor.systemMint.cgColor
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        return imageView
    }()
    
    let editProfileImageViewCover: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "camera.circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemGray6.withAlphaComponent(0.8)
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        imageView.isUserInteractionEnabled = true
                
        return imageView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        return indicator
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
        return tableView
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemMint
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOut))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editUserInfo))
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(applyLoadingAnimations), userInfo: nil, repeats: true)
        
        loadUserInfo()
    }
    
    override func viewDidLayoutSubviews() {
        let gesture = UIGestureRecognizer(target: self, action: #selector(editProfileImage))
        gesture.state = .began
        editProfileImageViewCover.addGestureRecognizer(gesture)
        
        view.addSubview(profileImageView)
        view.addSubview(nameField)
        view.addSubview(EditedProfileImageView)
        view.addSubview(editProfileImageViewCover)
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
        
        configureLayouts()
    }
    
    
    // MARK: - ACTIONS
    @objc private func applyLoadingAnimations() {
        if nameField.text!.count < 11 {
            nameField.text! += "."
        } else {
            nameField.text = "Loading "
        }
    }
    
    @objc private func editUserInfo() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        
        isEditingUserInfo = true
        
        nameField.isUserInteractionEnabled = true
        nameField.becomeFirstResponder()
        
        editProfileImageViewCover.isHidden = false
        
        tabBarController?.tabBar.isUserInteractionEnabled = false
        tabBarController?.tabBar.isHidden = true
        tableView.isUserInteractionEnabled = false
    }
    
    @objc private func saveEdit() {
        navigationItem.rightBarButtonItem?.tintColor = .systemGray6
        let newName = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if newName.count < 2 {
            let ac = UIAlertController(title: "Error", message: "Your user name is invalid, please try using another one.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {
                [weak self] _ in
                self?.cancelEdit()
            }))
            
            present(ac, animated: true)
            return
        }
        
        UserDefaults.standard.set(newName, forKey: "userName")
        
        if profileImageSelected {
            activityIndicator.startAnimating()
            if let imageData = EditedProfileImageView.image?.jpegData(compressionQuality: 0.5) {
                storage.child("profilesImages/\(userID).jpeg").putData(imageData) {
                    [weak self] _, error in
                    guard error == nil,
                          let strongSelf = self else { return }
                    
                    self?.profileImageView.image = strongSelf.EditedProfileImageView.image
                    self?.cancelEdit(save: true)
                }
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            storage.child("profilesImages/\(userID).jpeg").delete {
                error in
                guard error == nil else { return }
            }
            cancelEdit(save: true)
        }
    }
    
    @objc private func cancelEdit(save: Bool = false) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editUserInfo))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOut))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        
        activityIndicator.stopAnimating()
        
        nameField.isUserInteractionEnabled = false
        nameField.resignFirstResponder()
        nameField.text = UserDefaults.standard.string(forKey: "userName")
        
        EditedProfileImageView.isHidden = true
        
        editProfileImageViewCover.isHidden = true
        editProfileImageViewCover.tintColor = .systemGray6.withAlphaComponent(0.8)
        editProfileImageViewCover.image = UIImage(systemName: "camera.circle")
        
        isEditingUserInfo = false
        
        tabBarController?.tabBar.isUserInteractionEnabled = true
        tabBarController?.tabBar.isHidden = false
        tableView.isUserInteractionEnabled = true
                
        if save {
            database.child("users/\(userID)").updateChildValues(["name": nameField.text ?? "", "hasProfilePicture": profileImageSelected] as [String: Any])
            
            if profileImageSelected == false {
                storage.child("profilesImages/\(userID).jpeg").delete {
                    error in
                    guard error == nil else { return }
                }
            }
        }
    }
    
    @objc private func editProfileImage() {
        
        if isEditingUserInfo {
            nameField.resignFirstResponder()
            
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            ac.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: {
                [weak self] _ in
                self?.pickImage(useCamera: true)
            }))
            ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {
                [weak self] _ in
                self?.pickImage()
            }))
            ac.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
                [weak self] _ in
                self?.EditedProfileImageView.isHidden = false
                self?.EditedProfileImageView.image = UIImage(systemName: "person.crop.circle.fill")
                self?.profileImageSelected = false
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(ac, animated: true)
        }
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
    
    @objc private func logOut() {
        do {
            try auth.signOut()
            
            let destination = AuthenticationVC()
            destination.modalPresentationStyle = .fullScreen
            present(destination, animated: true)
        } catch {
            print("error")
        }
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            EditedProfileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            EditedProfileImageView.widthAnchor.constraint(equalToConstant: 150),
            EditedProfileImageView.heightAnchor.constraint(equalToConstant: 150),
            EditedProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            editProfileImageViewCover.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            editProfileImageViewCover.widthAnchor.constraint(equalToConstant: 150),
            editProfileImageViewCover.heightAnchor.constraint(equalToConstant: 150),
            editProfileImageViewCover.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    // MARK: - DATA
    private func loadUserInfo() {
        database.child("users/\(userID)").getData {
            [weak self] error, snapshot in
            guard error == nil,
                  let strongSelf = self,
                  let userInfo = snapshot?.value as? [String: Any] else {
                self?.loadUserInfo()
                return
            }
           
            self?.timer.invalidate()
            self?.nameField.text = userInfo["name"] as? String ?? ""
            UserDefaults.standard.set(userInfo["name"] as? String ?? "", forKey: "userName")
            
            if userInfo["hasProfilePicture"] as? Int ?? 0 == 1 {
                self?.storage.child("profilesImages/\(strongSelf.userID).jpeg").downloadURL(completion: {
                    url, error in
                    guard error == nil,
                          let url = url else {
                        self?.loadUserInfo()
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) {
                        data, _, error in
                        guard error == nil,
                              let data = data else {
                            self?.loadUserInfo()
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self?.profileImageView.image = UIImage(data: data)
                            self?.activityIndicator.stopAnimating()
                        }
                    }.resume()
                })
            } else {
                self?.profileImageView.tintColor = .systemMint
                self?.profileImageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}


extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        EditedProfileImageView.image = pickedImage
        EditedProfileImageView.isHidden = false
        profileImageSelected = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        var cellInfo = cell.defaultContentConfiguration()
        
        cellInfo.text = settings[indexPath.row]
        cellInfo.textProperties.font = .systemFont(ofSize: 14)
        cellInfo.image = UIImage(systemName: settingsImages[indexPath.row])
        
        cell.contentConfiguration = cellInfo
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = .systemMint
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
