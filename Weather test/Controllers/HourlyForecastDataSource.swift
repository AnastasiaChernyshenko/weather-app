//
//  HourlyForecastDataSource.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import UIKit

final class HourlyForecastDataSource: NSObject {
    var hoursWeather: [HourlyResponse]?
    
    func registerCollectionCells(in collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: HoursInfoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: HoursInfoCollectionViewCell.identifier)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension HourlyForecastDataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hoursWeather?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HoursInfoCollectionViewCell.identifier, for: indexPath) as! HoursInfoCollectionViewCell
        if let hourInfo = hoursWeather?[indexPath.row] {
            cell.configureWithHour(hourInfo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: 120.0)
    }
}


