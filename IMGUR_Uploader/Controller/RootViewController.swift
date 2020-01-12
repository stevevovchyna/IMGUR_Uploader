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
    private let dataSource = CustomDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
        collectionView.register(UINib.init(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
    }
}

extension RootViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        cell.activityIndicator.isHidden = !cell.activityIndicator.isHidden
        cell.activityIndicator.isAnimating ? cell.activityIndicator.stopAnimating() : cell.activityIndicator.startAnimating()
        guard let image = cell.userImage.image else { return }
        
        uploadImage(image)
        
        // TODO : cell must remember that there's an activity going on it
    }
    
}

//MARK:- private methods

extension RootViewController {
    
    // checking if user allows access to the photo library
   func checkAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                break
            case .denied, .restricted:
                DispatchQueue.main.async {
                    presentAlert(text: "Please provide Photo Library access in your Settings app", in: self)
                }
            case .notDetermined:
                DispatchQueue.main.async {
                    presentAlert(text: "Please provide Photo Library access in your Settings app", in: self)
                }
            default:
                break
            }
        }
    }
    
}
