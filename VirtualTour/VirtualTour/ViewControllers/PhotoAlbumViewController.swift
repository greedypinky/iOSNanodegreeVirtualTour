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
    let placeholder:String = "photoPlaceHolder"
    let removeButtonLabel = "Remove Selected Pictures"
    let defaultButtonLabel = "New Collection"
    
    let placeholderPic = "https://picsum.photos/200"
    var album:Album!
    var lat:Double?=0.0
    var lon:Double?=0.0
    var per_page:Int?=100
    var removePhotos:[IndexPath]?
    /**
     If no images are found a “No Images” label will be displayed.
     If there are images, then they will be displayed in a collection view.
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let photoSearch = PhotoSearch(lat: lat!, lon: lon!, api_key: FlickrAPIKey.key, in_gallery: true, per_page: per_page)
//        // TODO: Request Flickr Photos from the info we get from the PIN
//
//        VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
    }
    
    /**
     The app should determine how many images are available for the pin location, and display a placeholder image for each.
     */
    private func sendGetRequest() {
//        let photoSearch = PhotoSearch(lat: lat!, lon: lon!, api_key: FlickrAPIKey.key, in_gallery: true, per_page: per_page)
//        // TODO: Request Flickr Photos from the info we get from the PIN
//
//        VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newCollectionButton.isHidden = true
        newCollectionButton.isEnabled = false
        // Add the location pin for the MapView
        addPin()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
        
        // Configure set the cell with photo
        // photoPlaceHolder
        cell?.flickrImageView.image = UIImage(named: placeholder)
        
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: add removal of the item from Collection View
        // select will just grey out the cell
        // update the button label
        //collectionView.deleteItems(at: [indexPath])
        toggleButtonLabel()
        if newCollectionButton.titleLabel?.text == removeButtonLabel {
            removePhotos?.append(indexPath)
            // TODO: how to make the cell grey ??
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
            cell?.isOpaque = true
        } else {
            // TODO: remove the photo to be deleted
             removePhotos?.append(indexPath)
            // if the list count is zero reset the button to be the default button label
            if removePhotos?.count == 0 {
                newCollectionButton.titleLabel?.text = defaultButtonLabel
            }
        }
    }
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     } */
    
    
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

    func handleGetResponse(res:PhotoSearchResponse?, error:Error?) {
        guard let response = res else {
            let ac = UIAlertController(title: "Search Flickr photos", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in
                // tab OK to dismiss Alert Controller
                self.dismiss(animated: true, completion: nil)
            }
            ac.addAction(action)
            self.present(ac, animated: true, completion: nil)
         return
        }
        
        // reload the Collection View
        photoCollectionView.reloadData()
        // we need to show 'New Collection' button
        newCollectionButton.isHidden = false
        newCollectionButton.isEnabled = true
    }
    
    // When tab on New Collection or
    @IBAction func getNewCollection(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == defaultButtonLabel {
            // fetch new collection
            sendGetRequest()
            photoCollectionView.reloadData()
        } else {
            // remove the cell
            photoCollectionView.deleteItems(at: removePhotos!)
            photoCollectionView.reloadData()
        }
    }
    
    private func addPin() {
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        let annotation =  MKPointAnnotation()
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1))
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    
    private func toggleButtonLabel() {
        
        if newCollectionButton.titleLabel?.text == defaultButtonLabel {
            newCollectionButton.titleLabel?.text = removeButtonLabel
        } else {
            newCollectionButton.titleLabel?.text = defaultButtonLabel
        }
    }
}
