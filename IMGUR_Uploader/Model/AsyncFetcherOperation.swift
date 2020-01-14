//
//  AsyncFetchOperation.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AsyncFetcherOperation: Operation {
    let identifier: String
    let size: CGSize

    private(set) var fetchedData: DisplayData?

    init(identifier: String, with size: CGSize) {
        self.identifier = identifier
        self.size = size
    }

    override func main() {
        guard !isCancelled else { return }
        // setting options parameters for the request
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .fast
        options.isSynchronous = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeHiddenAssets = false
        
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: fetchOptions)
        PHImageManager.default().requestImage(for: asset.firstObject!, targetSize: size, contentMode: .aspectFit, options: options) { image, _ in
            let data = DisplayData()
            guard let image = image else { return }
            data.image = image
            self.fetchedData = data
        }
    }
}
