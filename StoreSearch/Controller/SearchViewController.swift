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
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    // MARK: - Outelets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Vairables and constants
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    // MARK: - View handler Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        // sets the tableview under the searchBar, the searchBar
        // intrisict height is 44, and the status bar height is 20
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0,
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
    
    // MARK: - Private Methods
    func iTunesURL(searchText: String) -> URL {
        // encodes the text, changing SPACE with %20 instead.
        // making it a valid url
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // the %@ part refers to the argument of type String
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    // MARK: - Alert
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Search bar delegates
extension SearchViewController: UISearchBarDelegate {
    
    // triggered when the search button is tapped.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            // if there is an active data task, this cancels it,
            // making sure that no old searches can ever get in the
            // way of the new search.
            dataTask?.cancel()
            
            // changing isLoading to true to activate the spinner
            isLoading = true
            tableView.reloadData()

            hasSearched = true
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!)
            
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                
                // error
                if let error = error as NSError?, error.code == -999 {
                    print("Failure! \(error)")
                    return
                    
                // no error and valid statusCode
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: < )
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        // we use return to avoid getting to the error popup below
                        return
                    }
                    
                // no error but invalid statusCode
                } else {
                    print("Failure! \(response!)")
                }
                
                // the code execustion reaches here only if something
                // went wrong.
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            dataTask?.resume()
        }
    }
    
    // extends the search bar to the status bar area, making it grey.
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

// MARK: - Table view delegates
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            // returns the loading cell
            return 1
        } else if !hasSearched {
            // no search has been done so returns nothing
            return 0
        } else if searchResults.count == 0 {
            // search has been done but no results
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            // look up the spinnner by it's tag
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // disables selecting a non existing cell
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
}
