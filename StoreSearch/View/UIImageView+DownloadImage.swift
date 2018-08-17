//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Matan Dahan on 17/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        // self is captured weak because it is possible that the UIImageView
        // no longer exist by the time the image has downloaded
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            [weak self] url, response, error in
            
            if error == nil, let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        })
        // start the download
        downloadTask.resume()
        return downloadTask
    }
}
