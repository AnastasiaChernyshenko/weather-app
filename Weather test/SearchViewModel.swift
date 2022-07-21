//
//  SearchViewModel.swift
//  Weather test
//
//  Created by Anastasia on 20.07.2022.
//

import Foundation
import CoreLocation
import MapKit

final class SearchViewModel: NSObject {
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
    
    private var selectedCity: MKLocalSearchCompletion?
    
    override init() {
        super.init()
        
        searchCompleter.resultTypes = .address
    }
    
    func setSearchResults(_ results: [MKLocalSearchCompletion]) {
        selectedCity = results.first
        searchResults = results
    }
    
    func setQuery(_ query: String) {
        searchCompleter.queryFragment = query
    }
    
    func selectIndexPath(_ indexPath: IndexPath, completion: StringBlock?) {
        let result = searchResults[indexPath.row]
        completion?(result.title)
        selectedCity = result
    }
    
    func catchCoordinateForSelectedCity(completion: @escaping ((CLLocationCoordinate2D?) -> Void)) {
        guard let city = selectedCity else {
            completion(nil)
            return
        }
        let searchRequest = MKLocalSearch.Request(completion: city)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completion(nil)
                return
            }
            completion(coordinate)
        }
    }
}
