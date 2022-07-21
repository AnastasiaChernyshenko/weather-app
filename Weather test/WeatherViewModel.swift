//
//  WeatherViewModel.swift
//  Weather test
//
//  Created by Anastasia on 20.07.2022.
//

import Foundation
import Combine
import CoreLocation

private let londonLocation = CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092)
private let defaultCity = "London"

final class WeatherViewModel: NSObject {
    
    @Published private(set) var cityWeather: WeatherResponse?
    @Published private(set) var city: String?
    @Published private(set) var selectedDay: DailyResponse?
    @Published private(set) var isLocationPermitted = false
    
    private var apiService: WeatherManager!
    private var locationManager: LocationManager!
    private var currentLocation: CLLocationCoordinate2D?
    private var selectedLocation: CLLocationCoordinate2D?
    private var cancellables: Set<AnyCancellable> = []
    
    
    override init() {
        super.init()
        
        apiService = WeatherManager()
        locationManager = LocationManager()
        bindLocationManager()
        getCurrentLocation()
    }
}

//MARK: - public interface
extension WeatherViewModel {
    func selectedItemId(indexPath: IndexPath) {
        var result: DailyResponse? = nil
        if indexPath.row >= 0 && indexPath.row < cityWeather?.daily.count ?? 0 {
            result = cityWeather?.daily[indexPath.row]
        }
        selectedDay = result
    }
    
    func locationSelected(_ location: CLLocationCoordinate2D? ) {
        guard location != nil else { return }
        selectedLocation = location
        getWeather()
        locationManager.getCityFromLocation(location) { [weak self] city in
            self?.city = city
        }
    }
    
    func getCurrentLocation() {
        guard selectedLocation != currentLocation || currentLocation == nil else { return }
        if currentLocation != nil {
            selectedLocation = currentLocation
            locationManager.getCityFromLocation(currentLocation) { [weak self] city in
                self?.city = city
            }
            getWeather()
        } else {
            locationManager.checkPermission(isNeedsRequest: true)
        }
    }
    
    func checkLocationPermission() {
        locationManager.checkPermission(isNeedsRequest: false)
    }
}

//MARK: - private - processing
private extension WeatherViewModel {
    func bindLocationManager() {
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.onNewLocationRecognized(location)
            }
            .store(in: &cancellables)
        
        locationManager.$isUserPermitLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.isLocationPermitted = bool
            }
            .store(in: &cancellables)
    }
    
    func getWeather() {
        guard let l = selectedLocation else { return }
        cityWeather = nil
        Task {
            cityWeather = try await WeatherManager().getDetailCityWeather(lat: l.latitude, lon: l.longitude)
            selectedDay = cityWeather?.daily.first
        }
    }

    func onNewLocationRecognized(_ location: CLLocationCoordinate2D?) {
        currentLocation = location
        if let l = location {
            selectedLocation = l
            locationManager.getCityFromLocation(l) { [weak self] city in
                self?.city = city
            }
        } else {
            selectedLocation = londonLocation
            city = defaultCity
        }
        getWeather()
    }
}
