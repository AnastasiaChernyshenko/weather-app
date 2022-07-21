//
//  DailyForecastDataSource.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import UIKit

final class DailyForecastDataSource: NSObject {
    var selectDayAction: IndexPathBlock?
    var selectedCell: Int = 0
    var daysWeather: [DailyResponse]? {
        didSet {
            selectedCell = 0
        }
    }
    
    func registerTableCells(in tableView: UITableView) {
        tableView.register(UINib(nibName: DayInfoTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DayInfoTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DailyForecastDataSource: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysWeather?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DayInfoTableViewCell.identifier, for: indexPath) as! DayInfoTableViewCell
        let day = daysWeather?[indexPath.row]
        cell.configure(isSelected: selectedCell == indexPath.row, day: day)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.row
        selectDayAction?(indexPath)
        tableView.reloadData()
    }
}
