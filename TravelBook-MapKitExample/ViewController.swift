//
//  ViewController.swift
//  TravelBook-MapKitExample
//
//  Created by Maddi on 2/12/20.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationNameText: UITextField!
    
    @IBOutlet weak var noteText: UITextField!
    var latitude:Double?
    var longitude:Double?
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        //setting options for locationManager
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //adding long press to create pin
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gesture:)))
        longPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPress)
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        self.view.addGestureRecognizer(tapView)
    }
    @objc func tappedView(){
        self.view.endEditing(true)
    }
    @objc func longPressed(gesture:UILongPressGestureRecognizer){
        if gesture.state == .began{
            let touchedPoint = gesture.location(in: self.mapView)
            let touchedMapCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedMapCoordinate
            latitude=touchedMapCoordinate.latitude
            longitude=touchedMapCoordinate.longitude
            
            annotation.title = locationNameText.text
            annotation.subtitle = noteText.text
            
            self.mapView.addAnnotation(annotation)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //getting user's location's lati and longi
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //setting zoom level
        //lower the value closer it is
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        
        //create the actual zoomed region to show in the user's location
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(locationNameText.text!, forKey: "name")
        newPlace.setValue(noteText.text!, forKey: "note")
        newPlace.setValue(latitude, forKey: "latitude")
        newPlace.setValue(longitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        if context.hasChanges{
            do {
                try context.save()
                print("Success in saving")
            } catch {
                print("Error in saving")
            }
        }
        navigationController?.popViewController(animated: true)
        
    }
    
}

