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
    var pin:Pin!
    var tabLocationLongtitude:Double!
    var tabLocationLatitude:Double!
    var selectedPinLocationCoordinate:CLLocationCoordinate2D?
    var fetchResultController:NSFetchedResultsController<Pin>!
    
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        fetchResultController = nil
        
        // TODO: When restarting the app, all Map pins are gone, none are restored.
        // Need to persist the PIN
        // TODO: After opening a Pin for the first time, if you go back and enter it again, the app crashes
    }
    
    private func addNavigationButton(){
        rightBarButton = UIBarButtonItem(image: nil, style: UIBarButtonItem.Style.plain, target:self, action: #selector(tabEditToShowDeletePinButton))
        rightBarButton?.title = "Edit"
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare data for navigate
        if segue.identifier == "showPhotoAlbum" {
            let photoAlbumVC  = segue.destination as! PhotoAlbumViewController
           ///var pin = Pin(context: dataController.viewContext)
           // pin.lat = tabLocationLatitude!
           // pin.long = tabLocationLongtitude!
            // TODO: NEED TO FIX THIS BUG !!
            photoAlbumVC.pin = pin
        }
    }
    
    @objc private func addPinToTheMap(longPressGestureRecongnizer:UIGestureRecognizer) {
        
        if (longPressGestureRecongnizer.state == UIGestureRecognizer.State.began)
        {
           print("add pin to map is called!")
            let touchPointAtMapView = longPressGestureRecongnizer.location(in: mapView)
            // transfer the touchpoint to map coordinate
            let mapCoordinate = mapView.convert(touchPointAtMapView, toCoordinateFrom: mapView)
            let location = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            if deletePinButton.isHidden {
                mapView.addAnnotation(annotation)
            }
            
            // TODO: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
            print("Save pin to core data only when it does not save before!")
            setupFetchedResultsController(lat: mapCoordinate.latitude, lon: mapCoordinate.longitude)
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
        if !editMode {
            tabLocationLongtitude = annotation?.coordinate.longitude
            tabLocationLatitude = annotation?.coordinate.latitude
            print("PIN did select with lat \(tabLocationLatitude) and long \(tabLocationLongtitude)")
            //  When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
            setupFetchedResultsController(lat: tabLocationLatitude, lon: tabLocationLongtitude)
            performSegue(withIdentifier: "showPhotoAlbum", sender: self)
        } else {
            print("will remove annotation!")
            // When a pin is tapped, remove the annotation from the mapView
            mapView.removeAnnotation(annotation!)
            // TODO: need to remove from core data as well
            let pin:Pin = Pin(context: dataController.viewContext)
            fetchResultController.managedObjectContext.delete(pin)
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
    
    // when will this be called?
    func addPinToCoreData(lat:Double, lon:Double){
        
        pin = Pin(context: dataController.viewContext)
        // HOW To ADD the photo ?
        pin.createDate = Date()
        pin.lat = lat
        pin.long = lon
        try? dataController.viewContext.save()
        print("Saved pin to core data")
    }
    
    // try to fetch the Album
    fileprivate func setupFetchedResultsController(lat:Double,lon:Double) {
        print("Pin: setup fetch result controller!")
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        // TODO: Need to  update the predicate
        let predicateLatitude = NSPredicate(format: "lat == %@", lat)
        let predicateLongtitude = NSPredicate(format: "long == %@", lon)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateLatitude, predicateLongtitude])
        fetchRequest.predicate = andPredicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            // if no data object is fetched, then persists the Pin
            if fetchResultController.fetchedObjects?.count == 0 {
                // let's create an new album
                addPinToCoreData(lat: lat, lon: lon)
            } else {
                print("we found existing pin")
                let existingPins:[Pin] = fetchResultController.fetchedObjects!
                pin = existingPins[0]
                print("we found existing pin with created date: \(pin.createDate)")
            }
        } catch {
            fatalError("Error when try to fetch the album \(error.localizedDescription)")
        }
    }

    // Retreive Pins from the Core Data and set the map
    fileprivate func initPinFromCoreData() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            // if there are persisted PIN core data
            if let count = fetchResultController.fetchedObjects?.count, count > 0 {
                // TODO: Set PIN to the map
                for pin in fetchResultController.fetchedObjects! {
                    let location = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    mapView.addAnnotation(annotation)
                }
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
