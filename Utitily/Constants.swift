//
//  Constants.swift
//  MyLocations
//
//  Created by Daniil Kim on 30.05.2021.
//

import Foundation
import UIKit

struct K {
    
    struct Images {
        
        static let tag = UIImage(named: "Tag")!
        static let locations = UIImage(named: "Locations")!
        static let map = UIImage(named: "Map")!
        
        static let pin = UIImage(named: "Pin")!
        static let user = UIImage(named: "User")!
        
        static let noPhoto = UIImage(named: "No Photo")!
    }
    
    struct Colors {
        
        static let tintColor = UIColor(red: 255,
                                       green: 238,
                                       blue: 136,
                                       alpha: 1)
        static let pinTintColor = UIColor(red: 0.32,
                                          green: 0.82,
                                          blue: 0.4,
                                          alpha: 1)
        static let annotationTintColor = UIColor(white: 0.0, alpha: 0.5)
        
        static let tableViewSeparatorColor = UIColor.white.withAlphaComponent(0.2)
        static let selectionColor = UIColor(white: 1.0, alpha: 0.3)
    }
    
}
