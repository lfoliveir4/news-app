//
//  SignUpViewController.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 25/03/23.
//

import Foundation
import UIKit
import FirebaseAuth

protocol SignUpViewControllerDelegate: AnyObject {
    func didSignUpComplete()
}

public final class SignUpViewController: UIViewController {
    weak var signUpDelegate: SignUpViewControllerDelegate?

    lazy var emailTextField: UITextField = {
        let email = UITextField()
        email.placeholder = "Email"
        email.backgroundColor = UIColor(white: 0, alpha: 0.03)
        email.borderStyle = .roundedRect
        email.keyboardType = .emailAddress
        email.autocapitalizationType = .none
        email.font = .systemFont(ofSize: 14)
        email.addTarget(self, action: #selector(handleChangeInputChange), for: .editingChanged)

        return email
    }()

    lazy var passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        password.backgroundColor = UIColor(white: 0, alpha: 0.03)
        password.borderStyle = .roundedRect
        password.font = .systemFont(ofSize: 14)
        password.addTarget(self, action: #selector(handleChangeInputChange), for: .editingChanged)

        return password
    }()

    lazy var signUpButton: UIButton = {
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("SignUp", for: .normal)
        signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        signUpButton.layer.cornerRadius = 5
        signUpButton.titleLabel?.font = .systemFont(ofSize: 14)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signUpButton.isEnabled = false

        return signUpButton
    }()

    lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attributedTitle = NSMutableAttributedString(
            string: "Já tem uma conta ",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        attributedTitle.append(
            NSAttributedString(
                string: "Sign In",
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)
                ]
            )
        )

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)

        return button
    }()

    @objc func handleChangeInputChange() {
        let isEmailValid = emailTextField.text?.isEmpty != true && passwordTextField.text?.isEmpty != true

        if isEmailValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }

    @objc func handleSignUp() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }

        // TODO: AUTH CREATE USER
        Auth.auth().createUser(withEmail: email, password: password, completion: { [self] (user, error) in
            if let err = error {
                showAlert(title: "", message: "Erro ao criar usuário: \(err)")
                return
            }
            
            signUpDelegate?.didSignUpComplete()
            dismiss(animated: true, completion: nil)
        })
    }

    @objc func handleAlreadyHaveAccount() {
        self.dismiss(animated: true, completion: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(alreadyHaveAccountButton)

        NSLayoutConstraint.activate([
            alreadyHaveAccountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            alreadyHaveAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            alreadyHaveAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            alreadyHaveAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        view.backgroundColor = .white
        setupInputField()
    }

    private func setupInputField() {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            signUpButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
