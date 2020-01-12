//
//  Utils.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

func presentAlert(text: String, in view: UIViewController) {
    let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
    view.present(alert, animated: true, completion: nil)
}
