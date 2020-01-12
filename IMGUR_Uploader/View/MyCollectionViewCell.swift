//
//  MyCollectionViewCell.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 11.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var representedId: String?
    var isLoading: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let screenWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = (screenWidth / 3) - 10
        activityIndicator.color = .black
        activityIndicator.isHidden = true
    }
    
    func configure(with data: DisplayData?) {
        guard let image = data?.image else { return }
        userImage.image = image
    }

}
