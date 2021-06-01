//
//  UITableViewCellExt.swift
//  MyLocations
//
//  Created by Daniil Kim on 21.05.2021.
//

import UIKit

extension UITableViewCell {
    
    func addViews(name: String? = nil,
                  leftLabel: UILabel? = nil,
                  rightView: UIView? = nil,
                  accessory: UITableViewCell.AccessoryType? = nil) {
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        let left: UILabel
        if let leftLabel = leftLabel {
            left = leftLabel
        } else {
            left = UILabel()
            left.text = name
        }
        
        left.textColor = .white
        
        contentView.addSubview(left)
        left.anchor(top: contentView.topAnchor,
                         leading: contentView.leadingAnchor,
                         bottom: nil,
                         padding: UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 0))
        
        var rightPadding: CGFloat = 8
        if let accessory = accessory {
            accessoryType = accessory
            rightPadding = 20
        }
        
        let leadingAnchor: NSLayoutXAxisAnchor
        let leftPadding: CGFloat
        if let labelText = left.text,
           labelText.isEmpty {
            leadingAnchor = contentView.leadingAnchor
            leftPadding = 10
        } else {
            leadingAnchor = left.trailingAnchor
            leftPadding = 50
        }
        
        if let right = rightView {
            contentView.addSubview(right)
            right.anchor(top: contentView.topAnchor,
                         leading: leadingAnchor,
                         bottom: contentView.bottomAnchor,
                         trailing: contentView.trailingAnchor,
                         padding: UIEdgeInsets(top: 10, left: leftPadding, bottom: 10, right: rightPadding))
        }
    }
    
}
