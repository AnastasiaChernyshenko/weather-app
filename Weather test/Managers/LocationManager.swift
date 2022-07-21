//
//  LocationManager.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    
    @Published private(set) var location: CLLocationCoordinate2D?
    @Published private(set) var isUserPermitLocation = false
    
    private let manager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    override init() {
        super.init()
        
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        location = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkPermission(isNeedsRequest: true)
    }
}

extension LocationManager {
    func getCityFromLocation(_ location: CLLocationCoordinate2D?, completion: ((String?) -> Void)?) {
        guard let l = location else {
            completion?(nil)
            return
        }
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: l.latitude, longitude: l.longitude), completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                completion?(placemark.locality)
            }
        })
    }
    
    func checkPermission(isNeedsRequest: Bool) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isUserPermitLocation = true
            if isNeedsRequest {
                manager.requestLocation()
            }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            if isNeedsRequest {
                manager.requestWhenInUseAuthorization()
            }
        case .denied:
            isUserPermitLocation = false
        default:
            break
        }
    }
}
