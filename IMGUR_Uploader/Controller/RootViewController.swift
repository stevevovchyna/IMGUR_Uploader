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
        collectionView.delegate = dataSource
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
                    Alert.showAlert(on: self, with: "Error", message: "Please provide Photo Library access in your Settings app")
                }
            case .notDetermined:
                DispatchQueue.main.async {
                    Alert.showAlert(on: self, with: "Error", message: "Please provide Photo Library access in your Settings app")
                }
            default:
                break
            }
        }
    }
}
