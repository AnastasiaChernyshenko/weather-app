//
//  MapViewController.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    let locationManager = CLLocationManager()
    var locationSelectedAction: LocationBlock?
    var showsUserLocation = false   
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapDidTap))
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.showsUserLocation = showsUserLocation
    }
}

private extension MapViewController {
    @objc
    func mapDidTap(gestureReconizer: UITapGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        let touchLocation = gestureReconizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let heldPoint = MKPointAnnotation()
        heldPoint.coordinate = locationCoordinate
        mapView.addAnnotation(heldPoint)
        locationSelectedAction?(locationCoordinate)
    }
}
