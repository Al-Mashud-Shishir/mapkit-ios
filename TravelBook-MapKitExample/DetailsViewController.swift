//
//  DetailsViewController.swift
//  TravelBook-MapKitExample
//
//  Created by Maddi on 2/12/20.
//

import UIKit
import MapKit
import CoreData

class DetailsViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UITableViewDelegate {
    
    var chosenId:UUID?
    var lati:Double?
    var longi:Double?
    var pinLocation:CLLocationCoordinate2D?
    var userCurLocation:CLLocation?
    var locationName:String?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameText: UILabel!
    
    @IBOutlet weak var noteText: UILabel!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //setting options for locationManager
        
        //        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        getIdData()
        //        getRoute()
    }
    func setMapPin(latitude:Double,longitude:Double) {
        pinLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //setting zoom level
        //lower the value closer it is
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        
        //create the actual zoomed region to show in the user's location
        let region = MKCoordinateRegion(center: pinLocation!, span: span)
        
        
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation!
        
        annotation.title = nameText.text
        annotation.subtitle = noteText.text
        
        
        self.mapView.addAnnotation(annotation)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView?.canShowCallout = true
            let btn = UIButton(type: UIButton.ButtonType.infoLight)
            pinView?.rightCalloutAccessoryView = btn
        }
        else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        getRoute()
        
    }
    //    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    //        userCurLocation = userLocation.location
    //        locationManager.stopUpdatingLocation()
    //    }
    func getRoute() {
        //        let sourceLocation = userCurLocation!.coordinate
        let sourceLocation = locationManager.location?.coordinate
        //        print(sourceLocation)
        //        print(pinLocation)
        //        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation!)
        let destinationPlacemark = MKPlacemark(coordinate: pinLocation!)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        print(directions)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .systemBlue
        
        return rendere
    }
    func getIdData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        let stringUUID = chosenId!.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID)
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            if let name = results[0].value(forKey: "name") as? String{
                nameText.text = name
                locationName = name
            }
            if let note = results[0].value(forKey: "note") as? String{
                noteText.text = note
            }
            if let lati = results[0].value(forKey: "latitude") as? Double{
                
                if let longi = results[0].value(forKey: "longitude") as? Double {
                    setMapPin(latitude: lati, longitude: longi)
                }
            }
            
        } catch {
            print("Error reading data")
        }
    }
    
}
