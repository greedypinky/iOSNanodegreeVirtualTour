//
//  PhotoAlbumViewController.swift
//  VirtualTour
//
//  Created by Rita Law on 2019-03-27.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var dataController:DataController!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    private let reuseIdentifier = "photoCell"
    //@IBOutlet weak var photoCollectionView: UICollectionView!
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
    
    // implicit unwrap
    // If the user selects a pin that already has a photo album then the Photo Album view should display the album and the New Collection button should be enabled.
    
    var fetchResultController:NSFetchedResultsController<Album>!
    
    /**
     If no images are found a “No Images” label will be displayed.
     If there are images, then they will be displayed in a collection view.
    */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.allowsMultipleSelection = true
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        if let count = album?.photos?.count {
            if count == 0 {
                showNoDataLabel()
            }
        } else {
            showNoDataLabel()
        }
        
        // TODO: If Album for the place exists, we do not need to fetch data from the web but load the persisted album data
        if let count = fetchResultController.sections?.count, count > 0  {
            // Need to fetch the Photos as well
        }
        
//
       let photoSearch = PhotoSearch(lat: lat!, lon: lon!, api_key: FlickrAPIKey.key, in_gallery: true, per_page: per_page)
//        // TODO: Request Flickr Photos from the info we get from the PIN
//
        VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        newCollectionButton.isHidden = true
        newCollectionButton.isEnabled = false
        // Add the location pin for the MapView
        addPin()
        
        // setupFetchedResultsController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchResultController = nil
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         return fetchResultController.sections?.count ?? 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // @NSManaged public var photos: NSSet?
        let sectionInfo = fetchResultController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    
    private func showNoDataLabel() {
        
        let frame = CGRect(x: 0, y: 0, width: photoCollectionView.bounds.width, height: photoCollectionView.bounds.height)
        var noDataLabel:UILabel = UILabel(frame: frame)
        view.addSubview(noDataLabel)
        noDataLabel.isHidden = false
        noDataLabel.text = "This pin has no images"
        noDataLabel.textAlignment = NSTextAlignment.center
        photoCollectionView.backgroundView = noDataLabel
        // photoCollectionView.isHidden = true
    }
    
    
  
    // MARK: Network request handler
    func handleGetResponse(res:PhotoSearchResponse?, error:Error?) {
        // PhotoSearchResponse
        // TODO: Set the PhotoSearchResponse data into the Core Data ?
        //  PhotoSearchResponse's photos:[FlickrPhoto]
        
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
        
        // TODO : we need to persist the Data into Core Data
        // First check if the Album for this place is exist, If not we need to create a new Album to persist
        // How can we add the Photos to Album ??
        /*
         struct PhotoSearchResponse:Decodable {
         let photos:PhotoSearchResult
         let stat:String
         }
         struct PhotoSearchResult:Decodable {
         let page:String
         let pages:String
         let perpage:String
         let total:String
         let photos:[FlickrPhoto]
         }
         */
        
        guard let flickrPhotos = response.photos.photos else {
            print("Error! no flickr photos")
            return
        }
        
        if flickrPhotos.count > 0 {
            // TODO: 1. Map the data to URL 2. create an Album and add core data
            // TODO: Traverse through the loop and map the URL
            // Add the URL to the Album
            // 1. NEED TO CREATE ALBUM HERE
            for photoInfo in flickrPhotos {
                let photoURL:URL = VirtualTourClient.mapPhotoToURL(id: photoInfo.id, secret: photoInfo.secret, farmid: photoInfo.farm, serverid: photoInfo.server)
                
                // TODO: need to add one by one into the Album
                
                // 2. ADD PHOTOS so that the Collection View can pick up the data from fetchResultController
            }
            
        }
        
        
        
        // reload the Collection View
        photoCollectionView.reloadData()
        // we need to show 'New Collection' button
        newCollectionButton.isHidden = false
        newCollectionButton.isEnabled = true
    }
    
    
    // MARK: Core Data functions
    
    func addAlbum(){
        let album = Album(context: dataController.viewContext)
        // HOW To ADD the photo ?
        try? dataController.viewContext.save()
        
    }
    
    func deleteAlbum() {
    
    }
    
    
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
    
    /**
     let predicateIsNumber = NSPredicate(format: "isStringOrNumber == %@", NSNumber(value: false))
     let predicateIsEnabled = NSPredicate(format: "isEnabled == %@", NSNumber(value: true))
     let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateIsNumber, predicateIsEnabled])
     
     //check here for the sender of the message
     let fetchRequestSender = NSFetchRequest<NSFetchRequestResult>(entityName: "Keyword")
     fetchRequestSender.predicate = andPredicate
     **/
    
    // try to fetch the Album
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Album> = Album.fetchRequest()
        // TODO: Need to  update the predicate
        let predicateLatitude = NSPredicate(format: "lat == %@", lat!)
        let predicateLongtitude = NSPredicate(format: "long == %@", lon!)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateLatitude, predicateLongtitude])
        fetchRequest.predicate = andPredicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch {
            fatalError("Error when try to fetch the album \(error.localizedDescription)")
        }
    }
    
    
    fileprivate func setupPhotosFetchedResultsController() {
//        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
       let predicate = NSPredicate(format: "album == %@", album)
//        fetchRequest.predicate = predicate
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(notebook)-notes")
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
    }
    
}

// MARK: extension with NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //
        
    }
}

