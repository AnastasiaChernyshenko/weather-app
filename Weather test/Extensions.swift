//
//  Extensions.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import UIKit
import CoreLocation

extension UIView {
    func addShadow(shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0), shadowRadius: CGFloat = 6.0, shadowOpacity: Float ) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red: CGFloat = CGFloat((hex >> 16) & 0xFF) / 255
        let green: CGFloat = CGFloat((hex >> 08) & 0xFF) / 255
        let blue: CGFloat = CGFloat((hex >> 00) & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func hexStringToUIColor (hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension Double {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

extension UIImageView {
    func loadFrom(url: URL) {
        UIImage.loadImageFrom(url: url) { [weak self] loadedImage in
            if let i = loadedImage {
                self?.image = i
            }
        }
    }
    
    func loadWeatherIcon(_ icon: String) {
        guard let url = URL(string: "http://openweathermap.org/img/wn/\(icon)@2x.png") else { return }
        UIImage.loadImageFrom(url: url) { [weak self] loadedImage in
            if let i = loadedImage {
                self?.image = i
            }
        }
    }
}

extension UIImage {
    static func loadImageFrom(url: URL, completion: ImageOptionalBlock?) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let d = data, let image = UIImage(data: d) {
                    completion?(image)
                } else {
                    completion?(nil)
                }
            }
        }.resume()
    }
}

extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil, buttonTitle: String = "OK") {
        assert(title != nil || message != nil, "Title or Message must not be nil")
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension UIColor {
    class var mainBlueColor:UIColor {
        return UIColor.hexStringToUIColor(hex: "4A90E2")
    }
    
    class var lightBlueColor:UIColor {
        return UIColor(red: 210.0/255.0, green: 105.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    }
}
