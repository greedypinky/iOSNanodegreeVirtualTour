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
    var pin:Pin!
    var lat:Double?=0.0
    var lon:Double?=0.0
    var per_page:Int?=10
    var removePhotos:[IndexPath]?
    
    
    // implicit unwrap
    // If the user selects a pin that already has a photo album then the Photo Album view should display the album and the New Collection button should be enabled.
    var fetchResultController:NSFetchedResultsController<Photo>!
    
    /**
     If no images are found a “No Images” label will be displayed.
     If there are images, then they will be displayed in a collection view.
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.allowsMultipleSelection = true
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        newCollectionButton.isHidden = true
        newCollectionButton.isEnabled = false
        
        // Add the location pin for the MapView
        addPin()
        // Show photos if there is persisted data, otherwise fetch from flickr
        showPhotos()
        
       
    }
    
    private func showPhotos() {
        
        guard pin != nil else {
            fatalError("Pin has no data!")
            showNoDataLabel()
            return
        }
        
        // When a Photo Album View is opened for a pin that does not yet have any photos, it initiates a download from Flickr.
        if pin.photos?.count == 0 {
            let photoSearch = PhotoSearch(lat: lat!, lon: lon!, api_key: FlickrAPI.key, in_gallery: true, per_page: per_page, page:1)
            VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
        } else {
            // If the Photo Album view is opened for a pin that previously had photos assigned, they are immediately displayed. No new download is needed.
            setupPhotosFetchedResultsController()
        }
        
       
    }
    
    /**
     The app should determine how many images are available for the pin location, and display a placeholder image for each
     The Photo Album view has a button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr. The new set should contain different images (if available) from the ones previously displayed. One way this can be achieved is by specifying a random value for the page parameter when making the request..
     */
    private func sendGetRequest() {
        // fetch 50 different set of photos randomly
        let page:Int = Int.random(in: 1...50)
        let photoSearch = PhotoSearch(lat: lat!, lon: lon!, api_key: FlickrAPI.key, in_gallery: true, per_page: per_page, page:page)
        // TODO: Request Flickr Photos from the info we get from the PIN
        VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fetchResultController = nil
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // @NSManaged public var photos: NSSet?
        guard let controller = fetchResultController else {
            return 0
        }
        let sectionInfo = controller.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchResultController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
        
        // Configure set the cell with photo
        // photoPlaceHolder
        if let image = photo.image {
            cell?.flickrImageView.image = UIImage(data: image)
        } else {
            cell?.flickrImageView.image = UIImage(named: placeholder)
        }
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
    
    
    
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//     func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//     return false
//     }
//
//     func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//     return false
//     }
    
//     func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//
//     }
    
    
    
    // When tab on New Collection or
    @IBAction func getNewCollection(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == defaultButtonLabel {
            // fetch new collection
            sendGetRequest()
            // DO we need to reload? if we have the core date delegate?
            photoCollectionView.reloadData()
        } else {
            // remove the cell
            photoCollectionView.deleteItems(at: removePhotos!)
            photoCollectionView.reloadData()
            removePhotos?.removeAll()
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
        
        guard let flickrPhotos = response.photos.photo else {
            print("Error! no flickr photos")
            return
        }
        
        if flickrPhotos.count > 0 {
            // TODO: 1. Map the data to URL 2. add photo and persists the photo
            // TODO: Traverse through the loop and map the URL
            for photoInfo in flickrPhotos {
                let photoURL:URL = VirtualTourClient.mapPhotoToURL(id: photoInfo.id, secret: photoInfo.secret, farmid: "\(photoInfo.farm)", serverid: photoInfo.server)
                // download the photo from URL, Handler should add the Photo into the Core Data!!
                print("map photo id: \(photoInfo.id)")
                print("mapped photo url: \(photoURL.absoluteString)")
                VirtualTourClient.photoImageDownload(url: photoURL, completionHandler: HandlePhotoSave(data:error:))
            }
            
            // reload the Collection View
            // photoCollectionView.reloadData()
            // we need to show 'New Collection' button
            newCollectionButton.isHidden = false
            newCollectionButton.isEnabled = true
            setupPhotosFetchedResultsController()
        }
        
        
        
    }
    
    
    func HandlePhotoSave(data:Data?, error:Error?) {
        
        guard let data = data else {
            fatalError("Unable to get download image : \(error?.localizedDescription)")
            return
        }
        
        let photoImage = UIImage(data: data)
        // Save image to Core Data
        addPhoto(image: photoImage!)
        print("Download Finished and added into Core Data")
    }
    
    // MARK: Core Data functions
    // Image is stored as Binary Type
    // The specifics of storing an image is left to Core Data by activating the “Allows External Storage” option.
    func addPhoto(image:UIImage) {
        let photo = Photo(context: dataController.viewContext)
        // HOW To add the photo image ?
        let jpegImage = image.jpegData(compressionQuality: 1)
        photo.image = jpegImage
        photo.createDate = Date()
        do {
             try dataController.viewContext.save()
             print("CORE DATA: Save photo!")
        } catch {
            fatalError("save photo error: \(error.localizedDescription)")
        }
    }
    
    func deletePhoto() {
    
    }
    
    fileprivate func setupPhotosFetchedResultsController() {
       let fetchRequestPhoto:NSFetchRequest<Photo> = Photo.fetchRequest()
       let predicate = NSPredicate(format: "pin == %@", pin)
       fetchRequestPhoto.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequestPhoto.sortDescriptors = [sortDescriptor]

        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequestPhoto, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self

        do {
            try fetchResultController.performFetch()
            print("data we can fetch is : \(fetchResultController.fetchedObjects?.count)")
            if let count = fetchResultController.fetchedObjects?.count {
                if count == 0 {
                    showNoDataLabel()
                }
            }
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}

// MARK: extension with NSFetchedResultsControllerDelegate

// A delegate protocol that describes the methods that will be called by the associated fetched results controller when the fetch results have changed.
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //
        switch type {
        case .insert:
            photoCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollectionView.deleteItems(at: [newIndexPath!])
            break
        case .update:
           photoCollectionView.reloadItems(at: [newIndexPath!])
        case .move:
            photoCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // reload data
        photoCollectionView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //
        
    }
}

