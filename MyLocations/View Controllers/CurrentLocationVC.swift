//
//  CurrentLocationVC.swift
//  MyLocations
//
//  Created by Daniil Kim on 19.05.2021.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationVC: UIViewController {
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var isUpdatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Smth is wrong with appDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    var soundID: SystemSoundID = 0
    
    // MARK: - UIViews
    
    let messageLabel = UILabel()
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    let latitudeLabel = UILabel()
    let longitudeLabel = UILabel()
    let latitudeValueLabel = UILabel()
    let longitudeValueLabel = UILabel()
    let addressLabel = UILabel()
    
    let tagButton = UIButton()
    let getButton = UIButton()
    
    var containerView = UIView()
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"),
                                  for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation),
                         for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    var isLogoVisible = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        loadSoundEffect("Sound.caf")
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Configure UI Elements
    
    private func setupViews() {
        // container view
        setupContainer()
        
        // configure views
        setupButtons()
        updateLabels()
    }
    
    private func setupContainer() {
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             leading: view.safeAreaLayoutGuide.leadingAnchor,
                             trailing: view.safeAreaLayoutGuide.trailingAnchor,
                             padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        setupMessageLabel()
        setupCoordinatesAndAddress()
    }
    
    private func updateLabels() {
        if let location = location {
            latitudeValueLabel.text = String(format: "%.8f",
                                             location.coordinate.latitude)
            longitudeValueLabel.text = String(format: "%.8f",
                                              location.coordinate.longitude)
            tagButton.isHidden = false
            
            messageLabel.text = ""
            latitudeLabel.text = "Latitude:"
            longitudeLabel.text = "Longitude:"
            
            if let placemark = placemark {
                addressLabel.text = createString(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if isUpdatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
            }
            messageLabel.text = statusMessage
            
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            latitudeValueLabel.text = ""
            longitudeValueLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.textAlignment = .center
        }
        configureGetButton()
    }
    
    private func setupMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.anchor(top: containerView.topAnchor,
                            leading: containerView.leadingAnchor,
                            trailing: containerView.trailingAnchor,
                            centerX: containerView.centerXAnchor,
                            padding: UIEdgeInsets.init(top: 50, left: 0, bottom: 0, right: 0))
        messageLabel.font = .systemFont(ofSize: 20, weight: .bold)
        messageLabel.textColor = .white
    }
    
    private func setupCoordinatesAndAddress() {
        // longitude and latitude labels
        let coordinateLabelsStack = UIStackView()
        coordinateLabelsStack.axis = .vertical
        coordinateLabelsStack.spacing = 20
        coordinateLabelsStack.addArrangedSubview(latitudeLabel)
        coordinateLabelsStack.addArrangedSubview(longitudeLabel)
        
        latitudeLabel.textColor = .white
        longitudeLabel.textColor = .white
        
        let coordinateValuesStack = UIStackView()
        coordinateValuesStack.axis = .vertical
        coordinateValuesStack.spacing = 20
        coordinateValuesStack.addArrangedSubview(latitudeValueLabel)
        coordinateValuesStack.addArrangedSubview(longitudeValueLabel)
        
        latitudeValueLabel.textColor = .white
        latitudeValueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        longitudeValueLabel.textColor = .white
        longitudeValueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let coordinatesStack = UIStackView()
        coordinatesStack.axis = .horizontal
        coordinatesStack.alignment = .fill
        coordinatesStack.addArrangedSubview(coordinateLabelsStack)
        coordinatesStack.addArrangedSubview(coordinateValuesStack)
        containerView.addSubview(coordinatesStack)
        
        coordinatesStack.anchor(top: messageLabel.bottomAnchor,
                                leading: containerView.leadingAnchor,
                                trailing: containerView.trailingAnchor,
                                padding: UIEdgeInsets(top: 50, left: 20, bottom: 0, right: 20))
        
        // addressLabel
        containerView.addSubview(addressLabel)
        addressLabel.anchor(top: coordinatesStack.bottomAnchor,
                            leading: containerView.leadingAnchor,
                            trailing: containerView.trailingAnchor,
                            padding: UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20))
        
        addressLabel.textColor = .white
    }
    
    private func configureGetButton() {
        if isUpdatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            loadingIndicator.color = .white
            containerView.addSubview(loadingIndicator)
            loadingIndicator.anchor(top: messageLabel.bottomAnchor,
                                    centerX: containerView.centerXAnchor,
                                    padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
            loadingIndicator.startAnimating()
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
    }
    
    private func setupButtons() {
        // tag button
        view.addSubview(tagButton)
        tagButton.anchor(top: addressLabel.bottomAnchor,
                         centerX: containerView.centerXAnchor,
                         padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        tagButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        tagButton.setTitle("Tag Location", for: .normal)
        tagButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        tagButton.isHidden = true
        tagButton.isEnabled = true
        tagButton.addTarget(self, action: #selector(tagLocation), for: .touchUpInside)
        
        // get button
        view.addSubview(getButton)
                getButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                 centerX: view.centerXAnchor,
                                 padding: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
                getButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        getButton.setTitle("Get My Location", for: .normal)
        getButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        getButton.isEnabled = true
        getButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
    }
    
    private func showLogoView() {
        if !isLogoVisible {
            isLogoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    private func hideLogoView() {
        if !isLogoVisible { return }
        
        isLogoVisible = false
        containerView.isHidden = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        animateLogoAndContent()
    }
    
    // MARK: - Helper Methods
    
    private func createString(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea,
                  separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    // MARK: - Selector Methods
    
    @objc private func getLocation() {
        let authStatus = locationManager.authorizationStatus
        
        if authStatus == .restricted || authStatus == .denied {
            showLocationServicesDeniedAlert()
        }
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if isLogoVisible {
            hideLogoView()
        }
        
        if isUpdatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
    
    @objc private func tagLocation() {
        let locationDetailsVC = LocationDetailsVC()
        locationDetailsVC.coordinate = location!.coordinate
        locationDetailsVC.placemark = placemark
        locationDetailsVC.managedObjectContext = managedObjectContext
        navigationController?.pushViewController(locationDetailsVC, animated: true)
    }
    
    @objc private func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1,
                                        userInfo: nil)
            updateLabels()
        }
    }
    
    // MARK: - Sound effects
    
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL,
                                                         &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        } else {
            print("No such sound found")
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }

}

// MARK: - Location Manager Delegate

extension CurrentLocationVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location Manager failed with error: ", error.localizedDescription)
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        if newLocation.horizontalAccuracy < 0 { return }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
            
            if distance > 0 {
                performingReverseGeocoding = false
            }
        }
        updateLabels()
        
        if !performingReverseGeocoding {
            print("*** Going to geocode")
            
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                self.lastGeocodingError = error
                if error == nil,
                   let placemarks = placemarks,
                   !placemarks.isEmpty {
                    
                    if self.placemark == nil {
                        print("playing sound")
                        self.playSoundEffect()
                    }
                    
                    self.placemark = placemarks.last!
                } else {
                    self.placemark = nil
                }
                
                self.performingReverseGeocoding = false
                self.updateLabels()
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    // MARK: - Location Methods
    
    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    private func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
            timer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(didTimeOut),
                                         userInfo: nil,
                                         repeats: false)
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(didTimeOut),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
}

// MARK: - CAAnimation Delegate

extension CurrentLocationVC: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    func animateLogoAndContent() {
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = .forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: .easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = .forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: .easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = .forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: .easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }

}
