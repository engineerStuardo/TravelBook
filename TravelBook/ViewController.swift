//
//  ViewController.swift
//  TravelBook
//
//  Created by Italo Stuardo on 29/3/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(keyboardGestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
            latitude = touchedCoordinates.latitude
            longitude = touchedCoordinates.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func save(_ sender: Any) {
        if nameText.text != "", commentText.text != "", latitude != 0.0, longitude != 0.0 {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            
            let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
            newPlace.setValue(nameText.text, forKey: "title")
            newPlace.setValue(commentText.text, forKey: "subtitle")
            newPlace.setValue(UUID(), forKey: "id")
            newPlace.setValue(latitude, forKey: "latitude")
            newPlace.setValue(longitude, forKey: "longitude")
            
            do{
                try context.save()
                let alert = UIAlertController(title: "Successfuly", message: "Place successfuly saved", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default) { _ in
                    print("Redirect user here")
                }
                alert.addAction(okButton)
                self.present(alert, animated: true)
            } catch {
                print("Error")
            }
        } else {
            let alert = UIAlertController(title: "Incomplete information", message: "Please fill all the information or choose a point in the map by holding tap for 3 seconds", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }
    }
    
}

