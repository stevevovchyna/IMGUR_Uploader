//
//  Utils.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import Photos

func fetchImage(with identifier: String, completion: @escaping (UIImage) -> ()) {
    let options = PHImageRequestOptions()
    options.version = .original
    options.isSynchronous = true
    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: .none)
    PHImageManager.default().requestImageData(for: asset.firstObject!, options: options) { (data, _, _, _)  in
        guard let data = data else { return }
        guard let image = UIImage(data: data) else { return }
        completion(image)
    }
}

extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
}
