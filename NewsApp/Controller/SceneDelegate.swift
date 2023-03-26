//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 16/02/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let dataController = DataController(modelName: "NewsApp")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        dataController.loadCoreData()
        let loginViewController = window?.rootViewController as! LoginViewController
        loginViewController.dataController = dataController
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        saveViewContext()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

