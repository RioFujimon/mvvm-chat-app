//
//  RegistrationController.swift
//  FireChat
//
//  Created by 藤門莉生 on 2021/09/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class RegistrationController: UIViewController {
    // Mark: - Properties
    
    private var viewModel: RegistrationViewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 90, weight: .light, scale: .large)
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: largeConfig), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(systemName: "envelope")!, textField: emailTextField)
    }()
    
    private lazy var fullnameContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(systemName: "person")!, textField: fullnameTextField)
    }()
    
    private lazy var usernameContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(systemName: "person")!, textField: usernameTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return InputContainerView(image: UIImage(systemName: "lock")!, textField: passwordTextField)
    }()
    
    private let emailTextField =  CustomTextField(placeholder: "Email")
    private let fullnameTextField =  CustomTextField(placeholder: "Full Name")
    private let usernameTextField =  CustomTextField(placeholder: "Username")
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.init(red: 255/255, green: 182/255, blue: 193/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.setHeight(height: 50)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor:  UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    // Mark: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // Mark: - Selectors
    @objc func handleRegistration() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }
        
        let credentials = RegistrationCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        showLoader(true, withText: "Signing You Up")
        
        AuthService.shared.createUser(credentials: credentials) { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                self.showLoader(false)
                return
            }
            
            self.showLoader(false)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        }else if sender == passwordTextField {
            viewModel.password = sender.text
        }else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        }else {
            viewModel.username = sender.text
        }
        
        checkFormStatus()
    }
    
    
    @objc func keyboardWillShow() {
        if  view.frame.origin.y == 0{
            self.view.frame.origin.y -= 120
        }
    }
    
    @objc func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // Mark: - Helpers
    func configureUI() {
        self.configureGradientLayer()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        plusPhotoButton.setDeimensions(height: 200, width: 200)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, fullnameContainerView, usernameContainerView,passwordContainerView,signUpButton])
        
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingBottom: 16, paddingRight: 32)
    }
    
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// Mark: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        profileImage = image
        self.plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        self.plusPhotoButton.layer.borderWidth = 3.0
        self.plusPhotoButton.layer.cornerRadius = 200 / 2
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .systemPink
        }else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.init(red: 255/255, green: 182/255, blue: 193/255, alpha: 1)
        }
    }
}
