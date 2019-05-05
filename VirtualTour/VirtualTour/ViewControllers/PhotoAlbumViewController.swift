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
    var pin:Pin!
    var per_page:Int=30
    var removePhotos:[IndexPath] = []
    var isRemoveMode:Bool = false
    var noDataLabel:UILabel!
    var fetchResultController:NSFetchedResultsController<Photo>!
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fetchResultController = nil
    }
    
    /**
     If no images are found a “No Images” label will be displayed.
     If there are images, then they will be displayed in a collection view.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup No Data label
        let frame = CGRect(x: 0, y: 0, width: photoCollectionView.bounds.width, height: photoCollectionView.bounds.height)
        noDataLabel = UILabel(frame: frame)
        view.addSubview(noDataLabel)
        noDataLabel.text = "This pin has no images"
        noDataLabel.textAlignment = NSTextAlignment.center
        showNoDataLabel(show: false)
        
        // setup ColllectionView's properties
        photoCollectionView.allowsMultipleSelection = true
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        // setup New Collection button's property
        newCollectionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        newCollectionButton.titleLabel?.lineBreakMode = .byTruncatingTail
        showNewCollectionButton(show:false)
        
        // Add the location pin for the MapView
        addPin()
        // Show photos if there is persisted data, otherwise fetch from flickr
        showPhotos()
    }
    
    private func showPhotos() {
        if pin.photos?.count == 0 {
            // First time Fetch if Pin has no photos
            print("First time fetch")
            let photoSearch = PhotoSearch(lat: pin.lat, lon: pin.long, api_key: FlickrAPI.key, in_gallery: true, per_page: per_page, page:1)
            VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
        } else {
        // If the Photo Album view is opened for a pin that previously had photos assigned, they are immediately displayed. No new download is needed.
            print("Fetch from core data!")
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
        let photoSearch = PhotoSearch(lat: pin.lat, lon: pin.long, api_key: FlickrAPI.key, in_gallery: true, per_page: per_page, page:page)
        // TODO: Request Flickr Photos from the info we get from the PIN
        VirtualTourClient.photoGetRequest(photoSearch: photoSearch, responseType: PhotoSearchResponse.self, completionHandler: handleGetResponse(res:error:))
    }
    
   
    
    
    //  New Collection 's IBAction method
    @IBAction func getNewCollection(_ sender: Any) {
        if newCollectionButton.titleLabel?.text == defaultButtonLabel {
            // remove the photos from Core Data first how??
            deletePhotoFromFetchedResult()
            // fetch new collection
            sendGetRequest()
            
        } else {
            // remove the cell
            if isRemoveMode {
                // TODO: Need to loop through the remove photo array and delete from CoreData
                deletePhotoFromRemovedPhotoArray()
                removePhotos.removeAll()
                isRemoveMode = false
                newCollectionButton.setTitle(defaultButtonLabel, for: [.normal,.selected,.highlighted])
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let controller = fetchResultController else {
            return 0
        }
        let sectionInfo = controller.sections?[section]
        guard let num = sectionInfo?.numberOfObjects, num > 0 else {
            showNoDataLabel(show: true)
            return 0
        }
        
        return sectionInfo?.numberOfObjects ?? 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchResultController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
        
        // Configure set the cell with photo
        // else set with photoPlaceHolder
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
        
            print("didSelectItem at \(indexPath.row)")

             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
             removePhotosLogic(selectedCellIndexpath: indexPath, collectionViewCell: cell!)
        
    }
    
    
    private func removePhotosLogic(selectedCellIndexpath:IndexPath, collectionViewCell:PhotoCollectionViewCell ){
        
        print("add photo indexpath to the array")
        // Need to check if no added into the array yet, then add
        if !removePhotos.contains(selectedCellIndexpath) {
           removePhotos.append(selectedCellIndexpath)
            // show the opacity of the cell
           collectionViewCell.opacityView.isHidden = false
            
        } else {
            // WHEN user touches the cell again THEN
            // 1. need to remove the cell from array
            // 2. need to set the opacity cell to Hidden to show the picture again
            // 3. if the removePhotos array count is 0, need to reset the buttons
            collectionViewCell.opacityView.isHidden = true
            let arrayIndex = removePhotos.firstIndex(of: selectedCellIndexpath)
            removePhotos.remove(at: arrayIndex!)
            // check if the array has count = 0
            if removePhotos.count == 0 {
                newCollectionButton.setTitle(defaultButtonLabel, for: [.selected,.normal,.highlighted])
                isRemoveMode = false
            }
        }
        
        print("what is the button title \(newCollectionButton.titleLabel?.text)")
        print("what is the mode? \(isRemoveMode)")
        if removePhotos.count > 0  {
            print("what is the mode? \(isRemoveMode)")
            newCollectionButton.setTitle(removeButtonLabel, for: [.selected,.normal,.highlighted])
            isRemoveMode = true
        } else {
            newCollectionButton.setTitle(defaultButtonLabel, for: [.selected,.normal,.highlighted])
            isRemoveMode = false
        }
    }
   
    
    // UX: Set up the MapView to have the annotation of the selected place
    private func addPin() {
        let coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
        let annotation =  MKPointAnnotation()
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1))
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    // UX: set visibility of the NoDataLabel
    private func showNoDataLabel(show:Bool) {
        if show {
            noDataLabel.isHidden = false
            photoCollectionView.backgroundView = noDataLabel
        } else {
            noDataLabel.isHidden = true
            photoCollectionView.backgroundView = nil
        }
    }
    
    // UX: set the visibility of the New Collection Button
    func showNewCollectionButton(show:Bool) {
        if show {
            newCollectionButton.isHidden = false
            newCollectionButton.isEnabled = true
        } else {
            newCollectionButton.isHidden = true
            newCollectionButton.isEnabled = false
        }
        
    }

    // MARK: Fetch Flickr photos request's handler
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
            // WHEN there are more than 1 photos from the fetch result
            // THEN 1. Map the data to create the photo URL 2. Download the photo from the URL 3. Persists the photo in Core Data
            for photoInfo in flickrPhotos {
                let photoURL:URL = VirtualTourClient.mapPhotoToURL(id: photoInfo.id, secret: photoInfo.secret, farmid: "\(photoInfo.farm)", serverid: photoInfo.server)
                // download the photo from URL, Handler should adds the Photo into the Core Data!!
                print("map photo id: \(photoInfo.id)")
                print("mapped photo url: \(photoURL.absoluteString)")
                VirtualTourClient.photoImageDownload(url: photoURL, completionHandler: HandlePhotoSave(data:error:))
            }
            
            // AND 2. We need to retrieve the Stored Photos into FetchedResultController to populate the CollectionView's data
            setupPhotosFetchedResultsController()
            // AND 3. We need to show 'New Collection' button
            showNewCollectionButton(show:true)
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
    
    // MARK: add photo into Core Data
    // Image is stored as Binary Type
    // The specifics of storing an image is left to Core Data by activating the “Allows External Storage” option.
    func addPhoto(image:UIImage) {
        let photo = Photo(context: dataController.viewContext)
        // HOW To add the photo image ?
        let jpegImage = image.jpegData(compressionQuality: 1)
        photo.image = jpegImage
        photo.createDate = Date()
        // fixed the issue suggested by mentor, otherwise cannot make a relationship with the Pin Object
        photo.pin = pin
        do {
             try dataController.viewContext.save()
             print("CORE DATA: Save photo!")
        } catch {
            fatalError("save photo error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Delete photo one by one from CoreData
    func deletePhotoFromRemovedPhotoArray() {
        
        if removePhotos.count > 0 {
            for indexpath in removePhotos {
                let photoToBeRemoved:NSManagedObject = fetchResultController.object(at: indexpath)
                fetchResultController.managedObjectContext.delete(photoToBeRemoved)
                try! fetchResultController.managedObjectContext.save()
            }
            
        }

    }
    
    // MARK: Delete photos from the Fetched Result
    func deletePhotoFromFetchedResult() -> () {
        
        guard let savedPhotos = fetchResultController.fetchedObjects else {
            print("No Photo in fetchedResults!")
            return
        }
        // we have saved photos
        for photoToBeDeleted in savedPhotos {
            // Delete each photo from Core Data
            fetchResultController.managedObjectContext.delete(photoToBeDeleted)
        }
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
                    print("no photos!")
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
            // when the fetched results are removed, the colletion view item will be removed
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

