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
        let data = DisplayData()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: .none)
        PHImageManager.default().requestImage(for: asset.firstObject!, targetSize: size, contentMode: .aspectFit, options: options) { image, _ in
            guard let image = image else { return }
            data.image = image
            self.fetchedData = data
        }
    }
}
