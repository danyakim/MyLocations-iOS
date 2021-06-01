//
//  MapVC.swift
//  MyLocations
//
//  Created by Daniil Kim on 29.05.2021.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {
    
    // MARK: - UIViews
    
    let mapView = MKMapView()
    
    // MARK: - Properties
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Smth is wrong with appDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    var locations = [Location]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        configureMapView()
        configureBarButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLocations()
        showUser()
    }
    
    // MARK: - Methods
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
            mapView.addAnnotations(locations)
        } catch {
            fatalError("Couldn't fetch locations for map")
        }
    }
    
    // MARK: - Private Methods
    
    private func configureMapView() {
        
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = true
        
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor,
                       leading: view.leadingAnchor,
                       bottom: view.bottomAnchor,
                       trailing: view.trailingAnchor)
    }
    
    private func configureBarButtons() {
        let locationsButton = UIBarButtonItem(image: K.Images.pin,
                                              style: .plain,
                                              target: self,
                                              action: #selector(showLocations))
        navigationItem.leftBarButtonItem = locationsButton
        
        let userButton = UIBarButtonItem(image: K.Images.user,
                                         style: .plain,
                                         target: self,
                                         action: #selector(showUser))
        navigationItem.rightBarButtonItem = userButton
    }
    
    private func getRegion(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90,
                                                 longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90,
                                                     longitude: -180)
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude,
                                       annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude,
                                        annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude,
                                           annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude,
                                            annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    // MARK: - Selector Methods
    
    @objc
    private func showUser() {
        let region = MKCoordinateRegion( center: mapView.userLocation.coordinate,
                                         latitudinalMeters: 1000,
                                         longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @objc
    private func showLocations() {
        let region = getRegion(for: locations)
        mapView.setRegion(region, animated: true)
    }
    
    @objc
    private func showLocationDetails(_ sender: UIButton) {
        let locationDetailsVC = LocationDetailsVC()
        locationDetailsVC.managedObjectContext = managedObjectContext
        locationDetailsVC.locationToEdit = locations[sender.tag]
        navigationController?.pushViewController(locationDetailsVC, animated: true)
    }
    
}

// MARK: - MKMapViewDelegate

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard annotation is Location else { return nil }
        guard let annotation = annotation as? Location else { return nil }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation,
                                              reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = K.Colors.pinTintColor
            pinView.tintColor = K.Colors.annotationTintColor
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self,
                                  action: #selector(showLocationDetails(_:)),
                                  for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            if let button = annotationView.rightCalloutAccessoryView as? UIButton,
               let index = locations.firstIndex(of: annotation) {
                button.tag = index
            } else {
                fatalError("ERROR")
            }
        }
        return annotationView
    }
    
}
