//
//  MyCollectionDataSource.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit
import Photos

/// - Tag: CustomDataSource
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    // MARK: Properties
    
    class Model {
        var allPhotos: PHFetchResult<PHAsset>? = nil
        
        init() {
            let fetchOptions = PHFetchOptions()
            self.allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        }
    }
    
    let models = Model()

    private let asyncFetcher = AsyncFetcher()

    // MARK:- UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = models.allPhotos?.count else { return 0 }
        return count
    }

    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? MyCollectionViewCell else {
            fatalError("Expected `\(MyCollectionViewCell.self)` type for reuseIdentifier imageCell. Check the configuration in Main.storyboard.")
        }
        guard let photos = models.allPhotos else { return cell }
        let id = photos.object(at: indexPath.row).localIdentifier
        cell.representedId = id
        // Checking if asyncFetcher has already fetched data for the specified identifier.
        if let fetchedData = asyncFetcher.fetchedData(for: id) {
            cell.configure(with: fetchedData)
        } else {
            cell.configure(with: nil)
            var size = cell.userImage.frame.size
            size.width *= 2
            size.height *= 2
            asyncFetcher.fetchAsync(id, with: size) { fetchedData in
                DispatchQueue.main.async {
              // checking if cell has been recycled by the collection view to represent other data.
                    guard cell.representedId == id else { return }
                    cell.configure(with: fetchedData)
                }
            }
        }
        return cell
    }

    // MARK:- UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? MyCollectionViewCell else {
                fatalError("Expected `\(MyCollectionViewCell.self)` type for reuseIdentifier imageCell. Check the configuration in Main.storyboard.")
            }
            guard let photos = models.allPhotos else { return }
            let id = photos.object(at: indexPath.row).localIdentifier
            asyncFetcher.fetchAsync(id, with: cell.userImage.frame.size)
        }
    }

    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            guard let photos = models.allPhotos else { return }
            let id = photos.object(at: indexPath.row).localIdentifier
            asyncFetcher.cancelFetch(id)
        }
    }
}

