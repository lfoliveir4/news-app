//
//  ProfileViewController.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 25/03/23.
//

import Foundation
import UIKit
import FirebaseAuth

public final class ProfileViewController: UIViewController {
    public override func viewDidLoad() {
        let userEmail = Auth.auth().currentUser

        super.viewDidLoad()

        let label = UILabel()
        label.text = userEmail?.email
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let button = UIButton()
        button.setTitle("Sair", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func handleSignOut() {
        do {
            try Auth.auth().signOut()
            if let storyboard = storyboard {
                let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                viewController.modalPresentationStyle = . fullScreen
                self.present(viewController, animated: true)
            }
        } catch {
            showAlert(title: "", message: "Error: \(error.localizedDescription)")
            print("error: \(error)")
        }
    }
}

