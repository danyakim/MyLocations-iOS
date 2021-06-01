//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Daniil Kim on 27.05.2021.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
    
    public var hasPhoto: Bool {
        return photoID != nil
    }
    
    public var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    public var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    public func removePhotoFile() {
        guard hasPhoto else { return }
        do {
            try FileManager.default.removeItem(at: photoURL)
        } catch {
            print("Error removing file: \(error)")
        }
    }
    
    public static func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
}
