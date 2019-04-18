//
//  LocationMapViewController.swift
//  VirtualTour
//
//  Created by Man Wai  Law on 2019-03-27.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
import MapKit

class LocationMapViewController: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deletePinButton: UIButton!
    
    var editMode = false
    var rightBarButton:UIBarButtonItem?
    
    var tabLocationLongtitude:Double?
    var tabLocationLatitude:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = "Virtual Tourist"
        addNavigationButton()
        deletePinButton.isHidden = true
        
        // Add the right - Edit / Done button
        var longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPinToTheMap))
        
        // Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        // When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(searchPhotosByPin))
        
        mapView.addGestureRecognizer(tabGesture)
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
        
       let location = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        
        tabLocationLongtitude = location.longitude
        tabLocationLatitude = location.latitude
        
        // navigate to the PhotoAlbum page
        performSegue(withIdentifier: "showPhotoAlbum", sender: self)
        } else {
            // TODO: remove the annotation from the mapView
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.removeAnnotation(annotation)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare data for navigate
        if segue.identifier == "showPhotoAlbum" {
            let photoAlbumVC  = segue.destination as! PhotoAlbumViewController
            photoAlbumVC.lat = tabLocationLatitude!
            photoAlbumVC.lon = tabLocationLongtitude!
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
            pinView?.canShowCallout = true
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
    
    /*
    Travel Locations Map
    When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
    
    
    The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
    
    
    Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
    
    
    When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
