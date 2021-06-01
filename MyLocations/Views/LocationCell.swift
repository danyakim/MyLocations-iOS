//
//  LocationTableViewCell.swift
//  MyLocations
//
//  Created by Daniil Kim on 30.05.2021.
//

import UIKit

class LocationCell: UITableViewCell {
    
    // MARK: - UIViews
    
    let descriptionLabel = UILabel()
    let addressLabel = UILabel()
    let thumbnail = UIImageView()
    
    // MARK: - Properties
    
    var image: UIImage?
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Methods
    
    func configure(with location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f",
                                       location.latitude,
                                       location.longitude)
        }
        
        if location.hasPhoto,
           let locationImage = location.photoImage {
            image = locationImage.resized(with: CGSize(width: 52, height: 52))
        } else {
            image = K.Images.noPhoto
        }
        
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        configureLabels()
        configureSelectionColor()
        
        let leadingPadding: NSLayoutXAxisAnchor
        
        if let image = image {
            contentView.addSubview(thumbnail)
            thumbnail.anchor(leading: contentView.leadingAnchor,
                             centerY: contentView.centerYAnchor,
                             padding: UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 0),
                             size: CGSize(width: 52, height: 52))
            
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.image = image
            thumbnail.layer.cornerRadius = thumbnail.image!.size.width / 2
            thumbnail.clipsToBounds = true
            
            leadingPadding = thumbnail.trailingAnchor
        } else {
            leadingPadding = contentView.leadingAnchor
        }
        
        let verticalStack = UIStackView(arrangedSubviews: [ descriptionLabel, addressLabel ])
        verticalStack.alignment = .leading
        verticalStack.axis = .vertical
        contentView.addSubview(verticalStack)
        verticalStack.anchor(top: contentView.topAnchor,
                             leading: leadingPadding,
                             bottom: contentView.bottomAnchor,
                             trailing: contentView.trailingAnchor,
                             padding: UIEdgeInsets(top: 4, left: 15, bottom: 8, right: 8))
    }
    
    private func configureLabels() {
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .bold)
        descriptionLabel.textColor = .white
        descriptionLabel.highlightedTextColor = .white
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .white.withAlphaComponent(0.6)
        addressLabel.highlightedTextColor = .white.withAlphaComponent(0.6)
    }
    
    private func configureSelectionColor() {
        let selection = UIView(frame: .zero)
        selection.backgroundColor = K.Colors.selectionColor
        selectedBackgroundView = selection
    }
}
