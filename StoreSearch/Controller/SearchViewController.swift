//
//  ViewController.swift
//  StoreSearch
//
//  Created by Matan Dahan on 14/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Outelets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARL: - Vairables and constants
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    
    // MARK: - View handler Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets the tableview under the searchBar, the searchBar
        // intrisict height is 44, and the status bar height is 20
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0,
                                              bottom: 0, right: 0)
    }
    
}

// MARK: - Search bar delegates
extension SearchViewController: UISearchBarDelegate {
    
    // triggered when the search button is tapped.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []
        if searchBar.text! != "justin bieber" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
    
    // extends the search bar to status bar area, making it grey.
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

// MARK: - Table view delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }
        else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}
