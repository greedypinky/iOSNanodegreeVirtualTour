//
//  PhotoAlbumViewController.swift
//  VirtualTour
//
//  Created by Man Wai  Law on 2019-03-27.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UICollectionViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    private let reuseIdentifier = "photoCell"
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    let placeholderPic = "https://picsum.photos/200"
    var album:Album!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // TODO: Request Flickr Photos from the info we get from the PIN
        
    }
    

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // @NSManaged public var photos: NSSet?
        return album.photos?.count ?? 0
        // return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure set the cell with photo
        
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    // Album operations on Photos
    /*
        @objc(addPhotosObject:)
        @NSManaged public func addToPhotos(_ value: Photo)
     
        @objc(removePhotosObject:)
        @NSManaged public func removeFromPhotos(_ value: Photo)
     
        @objc(addPhotos:)
        @NSManaged public func addToPhotos(_ values: NSSet)
     
        @objc(removePhotos:)
        @NSManaged public func removeFromPhotos(_ values: NSSet)
     */

}
