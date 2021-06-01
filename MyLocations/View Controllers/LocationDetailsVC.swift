//
//  LocationDetailsVC.swift
//  MyLocations
//
//  Created by Daniil Kim on 21.05.2021.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsVC: UITableViewController {
    
    // MARK: - Cells
    
    let descriptionCell = UITableViewCell()
    let categoryCell = UITableViewCell()
    let addPhotoCell = UITableViewCell()
    let latitudeCell = UITableViewCell()
    let longitudeCell = UITableViewCell()
    let addressCell = UITableViewCell()
    let dateCell = UITableViewCell()
    
    // MARK: - Cell Views
    
    let descriptionTextView = UITextView()
    let categoryLabel = UILabel()
    
    let imageView = UIImageView()
    let addPhotoLabel = UILabel()
    
    let latitudeLabel = UILabel()
    let longitudeLabel = UILabel()
    let addressLabel = UILabel()
    let dateLabel = UILabel()
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext!
    
    var observer: Any!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var image: UIImage?
    
    var date = Date()
    
    var categoryName: String {
        get {
            guard let category = categoryLabel.text
            else {
                return "No Category"
            }
            return category
            
        }
        set {
            categoryLabel.text = newValue
        }
    }
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude,
                                                        location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    // MARK: - Deinitialization
    
    deinit {
        print("*** deinit ", self)
        NotificationCenter.default.removeObserver(observer!)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create grouped tableView
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        
        // configure colors
        tableView.separatorColor = K.Colors.tableViewSeparatorColor
        tableView.backgroundColor = .black
        tableView.indicatorStyle = .white
        
        // enable editing
        descriptionTextView.becomeFirstResponder()
        
        // hide keyboard when tapped outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // set bar buttons
        configureBarButtons()
        
        // hide tab bar
        tabBarController?.tabBar.isHidden = true
        
        // listen for background notification
        listenForBackgroundNotification()
    }
    
    override func loadView() {
        super.loadView()
        
        // Location Edit
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let savedImage = location.photoImage {
                    image = savedImage
                }
            }
        } else {
            title = "Tag Location"
        }
        
        configureDescriptionCell()
        configureCategoryCell()
        configureAddPhotoCell()
        configureCoordinatesCell()
        configureAddressCell()
        configureDateCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Private Methods
    
    private func configureDescriptionCell() {
        descriptionCell.contentView.addSubview(descriptionTextView)
        descriptionTextView.anchor(top: descriptionCell.contentView.topAnchor,
                                   leading: descriptionCell.contentView.leadingAnchor,
                                   bottom: descriptionCell.contentView.bottomAnchor,
                                   trailing: descriptionCell.contentView.trailingAnchor,
                                   padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        descriptionTextView.text = descriptionText
        descriptionTextView.font = .systemFont(ofSize: 16)
        
        descriptionTextView.textColor = .white
        descriptionTextView.backgroundColor = .black
        descriptionCell.backgroundColor = .black
        
    }
    
    private func configureCategoryCell() {
        categoryCell.addViews(name: "Category",
                              rightView: categoryLabel,
                              accessory: .disclosureIndicator)
        
        categoryLabel.text = categoryName
        categoryLabel.textColor = .white.withAlphaComponent(0.6)
        categoryCell.backgroundColor = .black
    }
    
    private func configureAddPhotoCell() {
        imageView.contentMode = .scaleAspectFit
        if let image = image {
            show(image: image)
        } else {
            addPhotoLabel.text = "Add Photo"
        }
        addPhotoCell.addViews(leftLabel: addPhotoLabel,
                              rightView: imageView,
                              accessory: .disclosureIndicator)
        
        addPhotoCell.backgroundColor = .black
    }
    
    private func configureCoordinatesCell() {
        latitudeLabel.text = coordinate.latitude.description
        latitudeCell.addViews(name: "Latitude", rightView: latitudeLabel)
        
        longitudeLabel.text = coordinate.longitude.description
        longitudeCell.addViews(name: "Longitude", rightView: longitudeLabel)
        
        latitudeLabel.textColor = .white.withAlphaComponent(0.6)
        longitudeLabel.textColor = .white.withAlphaComponent(0.6)
        
        latitudeCell.backgroundColor = .black
        longitudeCell.backgroundColor = .black
    }
    
    private func configureAddressCell() {
        if let placemark = placemark {
            addressLabel.text = createString(from: placemark)
        } else {
            addressLabel.text = "Address Not Found"
        }
        addressCell.addViews(name: "Address", rightView: addressLabel)
        
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.numberOfLines = 2
        addressLabel.textColor = .white.withAlphaComponent(0.6)
        
        addressCell.backgroundColor = .black
    }
    
    private func configureDateCell() {
        dateLabel.text = format(date: date)
        dateCell.addViews(name: "Date", rightView: dateLabel)
        
        dateLabel.textColor = .white.withAlphaComponent(0.6)
        
        dateCell.backgroundColor = .black
    }
    
    private func configureBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(done))
        navigationItem.rightBarButtonItem = doneButton
    }
    private func createString(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea,
                 separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }
    
    private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    private func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        cell?.addViews(leftLabel: addPhotoLabel,
                       rightView: imageView)
        tableView.reloadData()
    }
    
    // MARK: - Selector Methods
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func done() {
        let hudView = HudView.hud(inView: view, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // save image
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    print("photo url : ", location.photoURL)
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 4
        default:
            fatalError("number of sections unknown")
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return descriptionCell
            case 1: return categoryCell
            default: fatalError("wrong row at section 0")
            }
        case 1:
            if indexPath.row == 0 {
                return addPhotoCell
            } else {
                fatalError("wrong row at section 1")
            }
        case 2:
            switch indexPath.row {
            case 0: return latitudeCell
            case 1: return longitudeCell
            case 2: return addressCell
            case 3: return dateCell
            default:
                fatalError("wrong row at section 2")
            }
        default:
            fatalError("Wrong number of cells")
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let selection = UIView(frame: CGRect.zero)
          selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
          cell.selectedBackgroundView = selection
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0,
           indexPath.row == 0 {
            return 88
        }
        if indexPath.section == 1,
           indexPath.row == 0 {
            if image == nil {
                return 44
            } else {
                return 260
            }
        }
        if indexPath.section == 2,
           indexPath.row == 2 {
            return 88
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                descriptionTextView.becomeFirstResponder()
            } else if indexPath.row == 1 {
                let categoryPicker = CategoryPickerTableVC()
                categoryPicker.delegate = self
                categoryPicker.selectedCategoryName = categoryName
                navigationController?.pushViewController(categoryPicker, animated: true)
            }
        }
        if indexPath.section == 1,
           indexPath.row == 0 {
            showPhotoMenu()
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "DESCRIPTION"
        }
        return nil
    }
    
    // MARK: - Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
}

// MARK: - CategoryPickerTableVC Delegate

extension LocationDetailsVC: CategoryPickerTableVCDelegate {
    
    func categoryPickerTableVC(picked category: String) {
        categoryName = category
    }
    
}

// MARK: - ImagePickerControllerDelegate

extension LocationDetailsVC: UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if let pickedImage = image {
            show(image: pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                          object: nil,
                                                          queue: OperationQueue.main) { [weak self] _ in
            guard let self = self else { return }
            if self.presentedViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
            self.descriptionTextView.resignFirstResponder()
        }
    }
    
    private func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    private func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(cancel)
        
        let takePhoto = UIAlertAction(title: "Take Photo",
                                      style: .default) { _ in
            self.takePhotoWithCamera()
        }
        alert.addAction(takePhoto)
        
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library",
                                              style: .default) { _ in
            self.choosePhotoFromLibrary()
        }
        alert.addAction(chooseFromLibrary)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.view.tintColor = K.Colors.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.view.tintColor = K.Colors.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
}
