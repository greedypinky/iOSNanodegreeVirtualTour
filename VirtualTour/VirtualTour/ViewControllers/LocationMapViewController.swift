//
//  LocationMapViewController.swift
//  VirtualTour
//
//  Created by Rita Law on 2019-03-27.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationMapViewController: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    
    var dataController:DataController!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deletePinButton: UIButton!
    
    var editMode = false
    var rightBarButton:UIBarButtonItem?
    
    var tabLocationLongtitude:Double?
    var tabLocationLatitude:Double?
    var selectedPinLocationCoordinate:CLLocationCoordinate2D?
    var album:Album!
    var fetchResultController:NSFetchedResultsController<Album>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        navigationItem.title = "Virtual Tourist"
        addNavigationButton()
        deletePinButton.isHidden = true
        
        // Add the right - Edit / Done button
        var longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPinToTheMap))
        
        // Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
    }
    
    private func addNavigationButton(){
        rightBarButton = UIBarButtonItem(image: nil, style: UIBarButtonItem.Style.plain, target:self, action: #selector(tabEditToShowDeletePinButton))
        rightBarButton?.title = "Edit"
        navigationItem.setRightBarButton(rightBarButton, animated: false)
        
    }
    
    @objc private func searchPhotosByPin(tabGesture:UIGestureRecognizer) {
        if !editMode {
        print("searchPhotosByPin")
       let touchPointAtMapView = tabGesture.location(in: mapView)
       let mapCoordinate = mapView.convert(touchPointAtMapView, toCoordinateFrom: mapView)
        
       let selectedPinLocationCoordinate = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        
        tabLocationLongtitude = selectedPinLocationCoordinate.longitude
        tabLocationLatitude = selectedPinLocationCoordinate.latitude
        
        setupFetchedResultsController()
            
        // navigate to the PhotoAlbum page
        performSegue(withIdentifier: "showPhotoAlbum", sender: self)
        } else {
            // TODO: remove the annotation from the mapView
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPinLocationCoordinate!
            mapView.removeAnnotation(annotation)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare data for navigate
        if segue.identifier == "showPhotoAlbum" {
            let photoAlbumVC  = segue.destination as! PhotoAlbumViewController
            photoAlbumVC.lat = tabLocationLatitude!
            photoAlbumVC.lon = tabLocationLongtitude!
            photoAlbumVC.album = album
        }
    }
    
    @objc private func addPinToTheMap(longPressGesture:UIGestureRecognizer) {
       
        let touchPointAtMapView = longPressGesture.location(in: mapView)
        // transfer the touchpoint to map coordinate
        let mapCoordinate = mapView.convert(touchPointAtMapView, toCoordinateFrom: mapView)
        let location = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        print("add pin to map! how ??")
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        // annotation.title = "place holder"
    
        if deletePinButton.isHidden {
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // for Pin rendering
        let annotationID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView()
            pinView?.canShowCallout = false
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }

  
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // TODO: when in Edit mode and user select the pin
        // Remove it from the MapView!
        print("did select")
        print("what is the edit mode? \(editMode)" )
        let annotation = view.annotation
        print("annotation 's lat \(annotation?.coordinate.latitude)")
        print("annotation 's lon \(annotation?.coordinate.longitude)")
        
        if !editMode {
            print("will perform segue to collectionview")
           
            tabLocationLongtitude = annotation?.coordinate.longitude
            tabLocationLatitude = annotation?.coordinate.latitude
            
            //  When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
            performSegue(withIdentifier: "showPhotoAlbum", sender: self)
        } else {
            print("will remove annotation!")
            // When a pin is tapped, remove the annotation from the mapView
            mapView.removeAnnotation(annotation!)
            
        }
    
    }
    

        
    @objc func tabEditToShowDeletePinButton() {
        print("tab edit!")
        if rightBarButton?.title == "Edit" {
            rightBarButton?.title = "Done"
            deletePinButton.isHidden = false
            editMode = true
        }
        else {
            rightBarButton?.title = "Edit"
            deletePinButton.isHidden = true
            editMode = false
        }
        
    }
    
    // MARK: save the zoom level when app is killed
    /**
 The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
 **/
    private func saveZoomLevel() {
        
    }
    
    /*
    Travel Locations Map
    When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
    
    
    The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
    
    
    Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
    
    
    When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
    */

    
    // MARK: Core Data functions
    func addAlbum(lat:Double, lon:Double){
        album = Album(context: dataController.viewContext)
        // HOW To ADD the photo ?
        album.createDate = Date()
        album.lat = lat
        album.long = lon
        try? dataController.viewContext.save()
        
        
    }
    
    // try to fetch the Album
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Album> = Album.fetchRequest()
        // TODO: Need to  update the predicate
        let predicateLatitude = NSPredicate(format: "lat == %@", tabLocationLatitude!)
        let predicateLongtitude = NSPredicate(format: "long == %@", tabLocationLongtitude!)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateLatitude, predicateLongtitude])
        fetchRequest.predicate = andPredicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            
            // if nothing we add the album
            if fetchResultController.fetchedObjects?.count == 0 {
                // let's create an new album
                addAlbum(lat: tabLocationLatitude!, lon: tabLocationLongtitude!)
            }
            
        } catch {
            fatalError("Error when try to fetch the album \(error.localizedDescription)")
        }
    }

}


// MARK: extension with NSFetchedResultsControllerDelegate
extension LocationMapViewController:NSFetchedResultsControllerDelegate {
    
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
