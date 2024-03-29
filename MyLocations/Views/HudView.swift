//
//  HudView.swift
//  MyLocations
//
//  Created by Daniil Kim on 26.05.2021.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    static func hud(inView view: UIView,
                    animated: Bool) -> HudView {
        let hud = HudView(frame: view.bounds)
        hud.isOpaque = false
        
        view.addSubview(hud)
        view.isUserInteractionEnabled = false
        
        hud.show(animated: animated)
        
        return hud
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let boundsCenterX = bounds.size.width / 2
        let boundsCenterY = bounds.size.height / 2
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30,
                                                      weight: .medium,
                                                      scale: .large)
        if let image = UIImage(systemName: "checkmark", withConfiguration: largeConfig)?.withTintColor(.white) {
            let imagePoint = CGPoint(
                x: boundsCenterX - round(image.size.width / 2),
                y: boundsCenterY - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white ]
        let textSize = text.size(withAttributes: attributes)
        let textPoint = CGPoint(
          x: boundsCenterX - round(textSize.width / 2),
          y: boundsCenterY - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attributes)
    }
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: []) {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    func hide() {
      superview?.isUserInteractionEnabled = true
      removeFromSuperview()
    }
    
}
