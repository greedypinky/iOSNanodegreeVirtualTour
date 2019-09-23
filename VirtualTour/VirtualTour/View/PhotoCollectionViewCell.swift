//
//  PhotoCollectionViewCell.swift
//  VirtualTour
//
//  Created by Man Wai  Law on 2019-04-14.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flickrImageView:UIImageView!
    
    @IBOutlet weak var opaqueView: UIImageView!
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                super.isSelected = true
                self.flickrImageView.alpha = 0.35
                print("selected")
            } else if newValue == false {
                super.isSelected = false
                self.flickrImageView.alpha = 1.0
                print("deselected")
            }
        }
    }
}
