//
//  Extensions.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 28/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    func topCorners(_ radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
    
    func bottomCorners(_ radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func makeViewCircle() {
        self.layer.cornerRadius = self.bounds.size.width / 2
        self.layer.masksToBounds = true
    }
}

extension UIColor {
    static let setlistifyBlack = UIColor(red: 52.0 / 255, green: 53.0 / 255, blue: 65.0 / 255, alpha: 1)
    static let setlistifyGreen = UIColor(red: 124.0 / 255, green: 203.0 / 255, blue: 188.0 / 255, alpha: 1)
    static let setlistifyGreenDark = UIColor(red: 115.0 / 255, green: 181.0 / 255, blue: 169.0 / 255, alpha: 1)
    static let setlistifyCream = UIColor(red: 245 / 255, green: 242 / 255, blue: 236 / 255, alpha: 1)
}

extension Date {
    
    static func dateFromEventString(eventDate: String) -> Date {
        
        //2016-03-25T14:48:50+0000 FORMAT
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: eventDate) ?? Date()
    }
    
    static func presentableDateFromDate(eventDate: String) -> String {
        
        let date = dateFromEventString(eventDate: eventDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: date)
    }
}