//
//  ViewController.swift
//  StoreSearch
//
//  Created by Matan Dahan on 14/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - TableViewCellIdentifiers
    private struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    // MARK: - Outelets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Vairables and constants
    private var landscapeVC: LandscapeViewController?
    private let search = Search()
    
    // MARK: - View handler Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        // sets the tableview under the searchBar, the searchBar
        // and navigation Item intrisict height is 44 each,
        // and the status bar height is 20
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0,
                                              bottom: 0, right: 0)
        
        // creating the custom nib cell
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        // creating the custom no results cell
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        // creating the custom loading cell
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        // making the keyboard visible, can start typing right away
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    //MARK: - Rotation to landscape handlers
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case.compact:
            showLandScape(with: coordinator)
        case .regular, .unspecified:
            hideLandScape(with: coordinator)
        }
    }
    
    private func showLandScape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    private func hideLandScape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParentViewController: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeVC = nil
            })
        }
    }
    
    // MARK: - Alert
    private func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Search bar delegates
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    private func performSearch() {
        search.performSearch(for: searchBar.text!, category: segmentedControl.selectedSegmentIndex, completion: {
            success in
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // extends the search bar to the status bar area, making it grey.
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

// MARK: - Table view delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            // returns the loading cell
            return 1
        } else if !search.hasSearched {
            // no search has been done so returns nothing
            return 0
        } else if search.searchResults.count == 0 {
            // search has been done but no results
            return 1
        } else {
            return search.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            // look up the spinnner by it's tag
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // set the sender to indexpath so you can get the object directly
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // disables selecting a non existing cell
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
}
