//
//  WeatherViewController.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import UIKit
import Combine
import PromiseKit

final class WeatherViewController: UIViewController {
    // MARK: - Private properties
    @IBOutlet private weak var cityButton: UIButton!
    @IBOutlet private weak var cityWeatherInfoContainerView: UIView!
    @IBOutlet private weak var mapButton: UIButton!
    @IBOutlet private weak var selectedDayLabel: UILabel!
    @IBOutlet private weak var selectedWeatherIcon: UIImageView!
    @IBOutlet private weak var selectedDayInfoTableView: UITableView!
    @IBOutlet private weak var daysForecastTableView: UITableView!
    @IBOutlet private weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet private weak var getWeatherForCurrentLocation: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var xibConstraints: [NSLayoutConstraint]!
    @IBOutlet private var selectedDayInfoView: [UIView]!
    
    private let selectedDayInfoDataSource = SelectedDayInfoDataSource()
    private let dailyForecastDataSource = DailyForecastDataSource()
    private let hourlyForecastDataSource = HourlyForecastDataSource()
    private var landscapeLayout = [NSLayoutConstraint]()
    private var weatherViewModel: WeatherViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSources()
        addTargets()
        setupConstraints()
        bindViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateOrientation()
    }
}

private extension WeatherViewController {
    func bindViewModel() {
        weatherViewModel = WeatherViewModel()
        
        weatherViewModel.$cityWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.onWeatherChange(weather)
            }
            .store(in: &cancellables)
        
        weatherViewModel.$city
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                self?.cityButton.setTitle(city, for: .normal)
            }
            .store(in: &cancellables)
        
        weatherViewModel.$isLocationPermitted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.getWeatherForCurrentLocation.isEnabled = bool
            }
            .store(in: &cancellables)
        
        weatherViewModel.$selectedDay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] day in
                self?.onSelectDay(day)
            }
            .store(in: &cancellables)
    }
    
    func setupDataSources() {
        selectedDayInfoDataSource.registerTableCells(in: selectedDayInfoTableView)
        selectedDayInfoTableView.dataSource = selectedDayInfoDataSource
        selectedDayInfoTableView.delegate = selectedDayInfoDataSource
        
        dailyForecastDataSource.registerTableCells(in: daysForecastTableView)
        daysForecastTableView.dataSource = dailyForecastDataSource
        daysForecastTableView.delegate = dailyForecastDataSource
        dailyForecastDataSource.selectDayAction = { [weak self] index in
            self?.weatherViewModel?.selectedItemId(indexPath: index)
        }
        
        hourlyForecastDataSource.registerCollectionCells(in: hourlyForecastCollectionView)
        hourlyForecastCollectionView.dataSource = hourlyForecastDataSource
        hourlyForecastCollectionView.delegate = hourlyForecastDataSource
    }
    
    func addTargets() {
        mapButton.addTarget(self, action: #selector(mapButtonDidTap), for: .touchUpInside)
        cityButton.addTarget(self, action: #selector(cityButtonDidTap), for: .touchUpInside)
        getWeatherForCurrentLocation.addTarget(self, action: #selector(getWeatherForCurrentLocationDidTap), for: .touchUpInside)
    }
    
    func setupConstraints() {
        landscapeLayout.append(cityButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0))
        landscapeLayout.append(cityWeatherInfoContainerView.topAnchor.constraint(equalTo: view.topAnchor))
        landscapeLayout.append(cityWeatherInfoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        landscapeLayout.append(cityWeatherInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        landscapeLayout.append(cityWeatherInfoContainerView.trailingAnchor.constraint(equalTo: daysForecastTableView.leadingAnchor))
        landscapeLayout.append(cityWeatherInfoContainerView.widthAnchor.constraint(equalToConstant: 300.0))
        
        landscapeLayout.append(hourlyForecastCollectionView.topAnchor.constraint(equalTo: view.topAnchor))
        landscapeLayout.append(hourlyForecastCollectionView.bottomAnchor.constraint(equalTo: daysForecastTableView.topAnchor))
        landscapeLayout.append(hourlyForecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        landscapeLayout.append(hourlyForecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300.0))
        
        landscapeLayout.append(daysForecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        landscapeLayout.append(daysForecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        landscapeLayout.append(daysForecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300.0))
    }
    
    func updateOrientation() {
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.deactivate(xibConstraints)
            NSLayoutConstraint.activate(landscapeLayout)
        } else {
            NSLayoutConstraint.deactivate(landscapeLayout)
            NSLayoutConstraint.activate(xibConstraints)
        }
        view.layoutIfNeeded()
    }
    
    func updateLoading(value: Bool) {
        selectedDayInfoView.forEach { $0.isHidden = value }
        
        activityIndicator.isHidden = !value
        value ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func onSelectDay(_ day: DailyResponse?) {
        selectedDayInfoDataSource.dayWeather = day
        let epocTime = TimeInterval(day?.dt ?? 0)
        let myDate = Date(timeIntervalSince1970: epocTime)
        selectedDayLabel.text = myDate.formatted(.dateTime.month().day())
        selectedDayInfoTableView.reloadData()
        if let icon = day?.weather.first?.icon {
            selectedWeatherIcon.loadWeatherIcon(icon)
        }
    }
    
    func onWeatherChange(_ weather: WeatherResponse?) {
        hourlyForecastDataSource.hoursWeather = weather?.hourly
        dailyForecastDataSource.daysWeather = weather?.daily
        updateLoading(value: weather == nil)
        
        hourlyForecastCollectionView.reloadData()
        daysForecastTableView.reloadData()
    }
    
    // MARK: - Actions
    @objc
    func mapButtonDidTap() {
        let vc = MapViewController()
        vc.locationSelectedAction = { [weak self] location in
            self?.weatherViewModel?.locationSelected(location)
        }
        firstly { [weak self] () -> Promise<Void> in
            self?.weatherViewModel.checkLocationPermission()
            return .value
        }.ensure { [weak self] in
            vc.showsUserLocation = self?.weatherViewModel.isLocationPermitted ?? false
            self?.navigationController?.pushViewController(vc, animated: true)
        }.cauterize()
    }
    
    @objc
    func cityButtonDidTap() {
        let vc = SearchViewController()
        vc.locationSelectedAction = { [weak self] location in
            self?.weatherViewModel?.locationSelected(location)
        }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    @objc
    func getWeatherForCurrentLocationDidTap() {
        weatherViewModel?.getCurrentLocation()
    }
}
