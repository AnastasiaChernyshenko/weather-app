//
//  SearchViewController.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import UIKit
import MapKit
import Combine

final class SearchViewController: UIViewController {
    // MARK: - Internal properties
    var locationSelectedAction: LocationBlock?
    
    // MARK: - Private properties
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var autoCompleteTableView: UITableView!
    @IBOutlet private weak var tableViewBottomDefaultConstraint: NSLayoutConstraint!
    
    private var viewModel: SearchViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SearchViewModel()
        setupLayout()
        registerForKeyboardNotifications()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        viewModel.setSearchResults(completer.results)
        autoCompleteTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        viewModel.searchResults.removeAll()
        autoCompleteTableView.reloadData()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setQuery(searchText)
        if searchText.isEmpty {
            searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = viewModel.searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         viewModel.selectIndexPath(indexPath) { [weak self] text in
             self?.searchBar.text = text
        }
    }
}

private extension SearchViewController {
    
    func setupLayout() {
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        searchButton.addTarget(self, action: #selector(searchButtonDidTap), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        viewModel.searchCompleter.delegate = self
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.backgroundColor = .white
        searchBar.tintColor = .separator
        searchBar.layer.cornerRadius = 12.0
        searchBar.layer.masksToBounds = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
    }
    
    // MARK: - Actions
    @objc
    func backButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func searchButtonDidTap() {
        viewModel.catchCoordinateForSelectedCity { [weak self] location in
            self?.locationSelectedAction?(location)
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Keyboard
private extension SearchViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardDidShow(notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let overlappedKeyboardHeight = keyboardFrame.height
        tableViewBottomDefaultConstraint.constant = overlappedKeyboardHeight
        
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: overlappedKeyboardHeight, right: 0.0)
        autoCompleteTableView.contentInset = contentInsets
        autoCompleteTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableViewBottomDefaultConstraint.constant = 0
        autoCompleteTableView.contentInset = contentInsets
        autoCompleteTableView.scrollIndicatorInsets = contentInsets
    }
}
