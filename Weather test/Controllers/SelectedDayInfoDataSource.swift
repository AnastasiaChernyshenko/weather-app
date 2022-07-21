//
//  SelectedDayInfoDataSource.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import UIKit

final class SelectedDayInfoDataSource: NSObject {
    var dayWeather: DailyResponse?
    
    enum Rows: Int, CaseIterable {
        case temp
        case humidity
        case wind
        
        var icon: UIImage? {
            switch self {
            case .temp:
                return UIImage(systemName: "thermometer")
            case .humidity:
                return UIImage(systemName: "humidity.fill")
            case .wind:
                return UIImage(systemName: "wind")
            }
        }
    }
    
    func registerTableCells(in tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SelectedDayInfoDataSource: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        guard let row = Rows(rawValue: indexPath.row), let day = dayWeather else { return UITableViewCell() }
        cell.imageView?.image = row.icon
        cell.imageView?.tintColor = .white
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        switch row {
        case .temp:
            cell.textLabel?.text = day.temp.max.roundDouble() + "/" + day.temp.min.roundDouble()
        case .humidity:
            cell.textLabel?.text = day.humidity.roundDouble()
        case .wind:
            cell.textLabel?.text = day.windSpeed.roundDouble()
        }
        return cell
    }
}
