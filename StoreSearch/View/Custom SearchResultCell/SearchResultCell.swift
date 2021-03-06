//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Matan Dahan on 14/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    // MARK: - Variables
    private var downloadTask: URLSessionDownloadTask?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // changes the color of the cell when it's selected
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized String Artist Name: Unknown")
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", result.artistName, result.type)
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }

}
