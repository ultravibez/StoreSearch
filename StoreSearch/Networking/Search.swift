//
//  Search.swift
//  StoreSearch
//
//  Created by Matan Dahan on 21/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    deinit {
        print("deinit \(self)")
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    enum Category: Int {
        case all      = 0
        case music    = 1
        case software = 2
        case ebooks   = 3
        
        var type: String {
            switch self {
            case .all:      return ""
            case .music:    return "musicTrack"
            case .software: return "software"
            case .ebooks:   return "ebook"
            }
        }
    }
    
    private var dataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            // if there is already a task running, cancel it.
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            state = .loading
            
            let url = iTunesURL(searchText: text, category: category)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                
                var newState = State.notSearchedYet
                
                var success = false
                // Was the search cancelled?
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200, let data = data {
                    
                    var searchResults = self.parse(data: data)
                    
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: < )
                        newState = .results(searchResults)
                    }
                    success = true
                }
                
                DispatchQueue.main.async {
                    self.state = newState
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    // MARK: - Private Methods
    private func iTunesURL(searchText: String, category: Category) -> URL {
        
        let locale = Locale.autoupdatingCurrent
        var language = locale.identifier
        let countryCode = locale.regionCode ?? "en_US"
        let kind = category.type
        if language == "en_IL" {
            language = "en_US"
        }
        
        // encodes the text, changing SPACE with %20 instead.
        // making it a valid url
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)" +
        "&lang=\(language)&country=\(countryCode)"
        
        let url = URL(string: urlString)
        print("URL: \(url!)")
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}
