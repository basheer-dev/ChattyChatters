//
//  NewPostVC.swift
//  ChattyChatters
//
//  Created by Basheer Abdulmalik on 21/06/2023.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class NewPostVC: UIViewController {
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    let userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    var didSelectImage: Bool = false
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemMint
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.45, green: 0.7, blue: 0.7, alpha: 0.5)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.layer.cornerRadius = 15
        textView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)).cgColor
        textView.layer.borderWidth = 1
        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        
        return textView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        
        return imageView
    }()
    
    let addImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .tinted()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "photo")
        button.configuration?.baseForegroundColor = .systemMint
        button.configuration?.baseBackgroundColor = .systemMint
        button.layer.cornerRadius = 25
        
        return button
    }()
    
    let cancelImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.configuration = .tinted()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "xmark")
        button.configuration?.baseForegroundColor = .systemRed
        button.configuration?.baseBackgroundColor = .systemRed
        button.isHidden = true
        
        return button
    }()
    
    let imageActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemMint
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(post))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem?.tintColor = .systemGray4
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        
        fetchProfileImage()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        textView.becomeFirstResponder()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        cancelImageButton.addTarget(self, action: #selector(cancelImage), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(textView)
        view.addSubview(addImageButton)
        view.addSubview(imageView)
        view.addSubview(cancelImageButton)
        view.addSubview(imageActivityIndicator)
        
        configureLayouts()
    }
    
    
    // MARK: - ACTIONS
    @objc private func addImage() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: {
            [weak self] _ in
            self?.pickImage(userCamera: true)
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {
            [weak self] _ in
            self?.pickImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc private func pickImage(userCamera: Bool = false) {
        let picker = UIImagePickerController()
        
        if userCamera {
            picker.sourceType = .camera
        }
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    @objc private func cancelImage() {
        imageView.isHidden = true
        cancelImageButton.isHidden = true
        addImageButton.isHidden = false
        didSelectImage = false
    }
    
    @objc private func post() {
        guard !textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines).isEmpty else { return }
        let postContent = textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)
        let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
        
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        
        let date = String(format: "%02d/%02d/%02d", day, month, year)
        let time = String(format: "%02d:%02d", hour, minute)
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .systemGray4
                
        if didSelectImage {
            imageActivityIndicator.startAnimating()
            
            database.child("posts").childByAutoId().setValue(
                [
                    "commentsCount": Int.random(in: 10...1000),
                    "content": postContent,
                    "date": date,
                    "hasImage": true,
                    "likesCount": Int.random(in: 10...1000),
                    "time": time,
                    "timestamp": timestamp,
                    "userID": userID
                ] as [String: Any] ) {
                    [weak self] error, reference in
                    guard error == nil,
                          let postID = reference.key else {
                        self?.imageActivityIndicator.stopAnimating()
                        return
                    }
                    if let image = self?.imageView.image?.jpegData(compressionQuality: 0.7) {
                        self?.storage.child("posts/\(postID).jpeg").putData(image, completion: {
                            _, error in
                            guard error == nil else {
                                self?.database.child("posts/\(postID)").updateChildValues(["hasImage": false])
                                self?.imageActivityIndicator.stopAnimating()
                                return
                            }
                            
                            self?.imageActivityIndicator.stopAnimating()
                            self?.dismiss(animated: true)
                        })
                    }
                }
        } else {
            database.child("posts").childByAutoId().setValue([
                "commentsCount": Int.random(in: 10...1000),
                "content": postContent,
                "date": date,
                "hasImage": false,
                "likesCount": Int.random(in: 10...1000),
                "time": time,
                "timestamp": timestamp,
                "userID": userID
            ] as [String: Any] ) {
                [weak self] error, _ in
                guard error == nil else { return }
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
    
    @objc private func adjustViewForKeyboard(notification: Notification) {
        guard let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboard.cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: 1) {
                self.addImageButton.transform = CGAffineTransform(translationX: 0, y: 30 - keyboardFrame.height)
            }
        } else {
            UIView.animate(withDuration: 1) {
                self.addImageButton.transform = .identity
            }
        }
    }
    
    
    // MARK: - LAYOUTS CONFIG
    private func configureLayouts() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            textView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            textView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            addImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 50),
            addImageButton.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
            cancelImageButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 5),
            
            imageActivityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageActivityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            
        ])
    }
    
    
    // MARK: - DATA
    private func fetchProfileImage() {
        database.child("users/\(userID)").getData {
            [weak self] error, snapshot in
            guard error == nil,
                  let strongSelf = self,
                  let userInfo = snapshot?.value as? [String: Any] else { return }

            if userInfo["hasProfilePicture"] as? Int ?? 0 == 1 {
                self?.storage.child("profilesImages/\(strongSelf.userID).jpeg").downloadURL(completion: {
                    url, error in
                    guard error == nil,
                          let url = url else { return }
                    
                    URLSession.shared.dataTask(with: url) {
                        data, _, error in
                        guard error == nil,
                              let data = data else { return }
                        
                        DispatchQueue.main.async {
                            self?.profileImageView.image = UIImage(data: data)
                        }
                    }.resume()
                })
            }
        }
    }
}


extension NewPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let pickedImage = info[.editedImage] as? UIImage else { return }
        addImageButton.isHidden = true
        imageView.isHidden = false
        cancelImageButton.isHidden = false
        imageView.image = pickedImage
        didSelectImage = true
    }
}


extension NewPostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)
        
        if !text.isEmpty {
            navigationItem.rightBarButtonItem?.tintColor = .systemMint
        } else {
            navigationItem.rightBarButtonItem?.tintColor = .systemGray4
        }
    }
}
