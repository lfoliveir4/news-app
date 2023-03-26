//
//  Alert+Extension.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 25/03/23.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in  completion?() }

        alert.addAction(action)
        present(alert, animated: true)
    }
}
