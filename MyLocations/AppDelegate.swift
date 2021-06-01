//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Daniil Kim on 19.05.2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if let tabController = window?.rootViewController as? UITabBarController,
//           let tabViewControllers = tabController.viewControllers {
//            var navController: UINavigationController?
//
//            navController = tabViewControllers[0] as? UINavigationController
//            if let navController = navController,
//               let controller = navController.viewControllers.first as? CurrentLocationVC {
//                controller.managedObjectContext = persistentContainer.viewContext
//            }
//
//            navController = tabViewControllers[1] as? UINavigationController
//            if let navController = navController,
//               let controller2 = navController.viewControllers.first as? LocationsTableVC {
//                controller2.managedObjectContext = persistentContainer.viewContext
//
//            }
//        }
//
        customizeAppearance()
        listenForFatalCoreDataNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Helper methods
    
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(
            forName: coreDataSaveFailedNotification,
            object: nil, queue: OperationQueue.main,
            using: { notification in
                
                let message = """
        There was a fatal error in the app and it cannot continue.
        Press OK to terminate the app. Sorry for the inconvenience.
        """
                
                let alert = UIAlertController(
                    title: "Internal Error", message: message,
                    preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK",
                                           style: .default) { _ in
                    let exception = NSException(
                        name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate
                else {
                    return
                }
                
                let tabController = sceneDelegate.window!.rootViewController!
                tabController.present(alert, animated: true, completion: nil)
            })
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = K.Colors.tintColor
    }
    
}
