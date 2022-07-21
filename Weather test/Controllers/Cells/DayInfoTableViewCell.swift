//
//  DayInfoTableViewCell.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import UIKit

final class DayInfoTableViewCell: UITableViewCell {

    static let identifier = "DayInfoTableViewCell"
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        weatherImageView.image = nil
    }
    
    func configure(isSelected: Bool, day: DailyResponse?) {
        guard let d = day else { return }
        let epocTime = TimeInterval(d.dt)
        let myDate = Date(timeIntervalSince1970: epocTime)
        dayLabel.text = myDate.formatted(.dateTime.month().day())
        tempLabel.text =  d.temp.max.roundDouble() + "/" +  d.temp.min.roundDouble()
        if let icon =  d.weather.first?.icon{
            weatherImageView.loadWeatherIcon(icon)
        }
        let color: UIColor = isSelected ? .mainBlueColor : .black
        dayLabel.textColor = color
        tempLabel.textColor = color
        weatherImageView.tintColor = color
        if isSelected {
            addShadow(shadowColor: .mainBlueColor, shadowOpacity: 0.2)
        } else {
            addShadow(shadowColor: .clear, shadowOffset: CGSize(width: 0, height: 0), shadowRadius: 0.0, shadowOpacity: 0.0)
        }
    }
}
