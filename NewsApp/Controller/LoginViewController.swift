//
//  LoginViewController.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 11/03/23.
//

import UIKit
import FirebaseAuth
import CoreData

class LoginViewController: UIViewController {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabelPressed: UILabel!

    var dataController: DataController!

    // MARK: - Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        signUpLabelPressed.isUserInteractionEnabled = true
        signUpLabelPressed.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Override
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Auth.auth().currentUser != nil {
            self.completeLogin()
        }
    }

    // MARK: - Objc funcs
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        let signUpViewController = SignUpViewController()
        signUpViewController.signUpDelegate = self

        self.present(signUpViewController, animated: true)
    }

    // MARK: - @IBAction
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = userTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }

        Auth.auth().signIn(withEmail: email, password: password, completion: { [self] (user, error) in
            if error != nil {
                showAlert(title: "", message: "\(error?.localizedDescription)")
            }
            completeLogin()
        })
    }

    // MARK: - Private funcs
    private func completeLogin() {
        DispatchQueue.main.async {
            let viewController = self.storyboard!.instantiateViewController(
                withIdentifier: "MainNavigationController"
            ) as! UINavigationController

            let rootViewController = viewController.topViewController as! UITabBarController

            let mainTableViewController = rootViewController.viewControllers![0] as! MainTableViewController

            mainTableViewController.dataController = self.dataController
            
            self.present(viewController, animated: true)
        }
    }

    private func validateTextField() -> Bool {
        if userTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return true
        } else {
            return false
        }
    }
}

extension LoginViewController: SignUpViewControllerDelegate {
    func didSignUpComplete() {
        completeLogin()
    }
}
