//
//  HoursInfoCollectionViewCell.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import UIKit

final class HoursInfoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HoursInfoCollectionViewCell"
    
    @IBOutlet private weak var hourLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tempLabel: UILabel!
    
    func configureWithHour(_ hour: HourlyResponse) {
        let epocTime = TimeInterval(hour.dt)
        let myDate = Date(timeIntervalSince1970: epocTime)
        hourLabel.text = myDate.formatted(.dateTime.hour().minute())
        if let icon = hour.weather.first?.icon {
            imageView.loadWeatherIcon(icon)
        }
        tempLabel.text = hour.temp.roundDouble()
    }
}
