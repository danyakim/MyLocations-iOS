//
//  TabBarController.swift
//  MyLocations
//
//  Created by Daniil Kim on 19.05.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVCs()
    }
    
    // MARK: - Private Methods
    
    private func setupVCs() {
        viewControllers = [
            createNavController(for: CurrentLocationVC(),
                                title: "Tag",
                                image: K.Images.tag),
            createNavController(for: LocationsTableVC(),
                                title: "Locations",
                                image: K.Images.locations),
            createNavController(for: MapVC(),
                                title: "Map",
                                image: K.Images.map)
        ]
    }
    
    private func createVC(for vc: UIViewController,
                          title: String,
                          image: UIImage) -> UIViewController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        return vc
    }
    
    private func createNavController(for root: UIViewController,
                                     title: String,
                                     image: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: root)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
    
}
