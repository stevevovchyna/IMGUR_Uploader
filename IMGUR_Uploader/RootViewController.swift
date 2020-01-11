//
//  ViewController.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 11.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit
import Photos

class RootViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var allPhotos : PHFetchResult<PHAsset>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                DispatchQueue.main.async {
                    let fetchOptions = PHFetchOptions()
                    self.allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                    self.collectionView.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            default:
                break
            }
        }
        collectionView.register(UINib.init(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
    }
}

extension RootViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! MyCollectionViewCell
        if let photos = allPhotos, photos.count > 0 {
            let asset = photos.object(at: indexPath.row)
            cell.userImage.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: cell.userImage.frame.size)
        }
        return cell
    }
}

extension UIImageView{
 func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
    let options = PHImageRequestOptions()
    options.version = .original
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
        guard let image = image else { return }
        switch contentMode {
        case .aspectFill:
            self.contentMode = .scaleAspectFill
        case .aspectFit:
            self.contentMode = .scaleAspectFit
        default:
            break
        }
        self.image = image
    }
   }
}
