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
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegate {
    // MARK: Properties
    
    let uploadManager = ImageUploader()
    let linkManager = LinkManager()
    var allOperations: [String] = []
    
    // model that fetches list of all images available
    class Model {
        
        var allPhotos: PHFetchResult<PHAsset>? = nil
        var size: CGSize = CGSize(width: 0, height: 0)
        
        init() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            let screenWidth = UIScreen.main.bounds.size.width
            size = CGSize(width: screenWidth / 3, height: screenWidth / 3)
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
        // obtaining imageID needed for futher process
        guard let photos = models.allPhotos else { return cell }
        let id = photos.object(at: indexPath.row).localIdentifier
        cell.representedId = id
        
        let trigger = allOperations.contains(id) ? false : true
        // Checking if asyncFetcher has already fetched data for the specified identifier.
        if let fetchedData = asyncFetcher.fetchedData(for: id) {
            cell.configure(with: fetchedData)
            cell.isLoading = !trigger
        } else {
            cell.configure(with: nil)
            asyncFetcher.fetchAsync(id, with: models.size) { fetchedData in
                DispatchQueue.main.async {
              // checking if cell has been recycled by the collection view to represent other data.
                    guard cell.representedId == id else { return }
                    cell.configure(with: fetchedData)
                    cell.isLoading = !trigger
                }
            }
        }
        return cell
    }

    // MARK:- UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        guard let photos = models.allPhotos else { return }
        for indexPath in indexPaths {
            let id = photos.object(at: indexPath.row).localIdentifier
            asyncFetcher.fetchAsync(id, with: models.size)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell else { return }
        cell.isLoading = true
        //getting needed image ID
        guard let photos = models.allPhotos else { return }
        let id = photos.object(at: indexPath.row).localIdentifier
        cell.representedId = id
        // making sure user dosen't click on the image too many times - one upload per picture, please
        guard !allOperations.contains(id) else { return }
        //adding our operation to the array of current operations to track them
        allOperations.append(id)
        // getting an image from the phot library
        fetchImage(with: id) { image in
            // uploading image
            self.uploadManager.uploadImage(image) { result in
                switch result {
                case .error(let err):
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "alert"), object: ["message": err])
                    }
                case .success(let link):
                    DispatchQueue.main.async {
                        // saving the link to the local storage
                        let newLink = self.linkManager.newLink()
                        newLink.link = link
                        self.linkManager.save()
                    }
                }
                // checking if the cell haven't been used
                guard cell.representedId == id else { return }
                cell.isLoading = false
                self.allOperations = self.allOperations.filter{ $0 != id }
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

