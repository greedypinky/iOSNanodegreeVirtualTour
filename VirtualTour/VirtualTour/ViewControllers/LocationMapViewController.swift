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
    
    // TODO: Delete the pin from the mapview
//    @IBAction func tabPinToDelete(_ sender: Any) {
//        print("Delete pin")
//    }
    
    var editMode = false
    var rightBarButton:UIBarButtonItem?
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
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
    }
    
    private func addNavigationButton(){
        rightBarButton = UIBarButtonItem(image: nil, style: UIBarButtonItem.Style.plain, target:self, action: #selector(tabEditToShowDeletePinButton))
        rightBarButton?.title = "Edit"
        navigationItem.setRightBarButton(rightBarButton, animated: false)
        
    }
    
    
    @objc private func addPinToTheMap(longPressGesture:UIGestureRecognizer) {
        let touchPointAtMapView = longPressGesture.location(in: mapView)
        // transfer the touchpoint to map coordinate
        let mapCoordinate = mapView.convert(touchPointAtMapView, toCoordinateFrom: mapView)
        let location = CLLocationCoordinate2D(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        print("add pin to map! how ??")
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        // TODO: need to add the annotation info into CORE DATA
        mapView.addAnnotation(annotation)
        
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
        }
        else {
            rightBarButton?.title = "Edit"
            deletePinButton.isHidden = true
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
