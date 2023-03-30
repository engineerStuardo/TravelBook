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

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var placeTitle: String = ""
    var placeSubtitle: String = ""
    var placeId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(keyboardGestureRecognizer)
        
        if placeTitle != "" {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "id= %@", placeId.uuidString)
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        nameText.text = title
                    }
                    
                    if let comment = result.value(forKey: "subtitle") as? String {
                        commentText.text = comment
                        placeSubtitle = comment
                    }
                    
                    if let lat = result.value(forKey: "latitude") as? Double, let lng = result.value(forKey: "longitude") as? Double {
                        let addAnnotation = MKPointAnnotation()
                        addAnnotation.title = placeTitle
                        addAnnotation.subtitle = placeSubtitle
                        addAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.mapView.addAnnotation(addAnnotation)
                        focusLocation(lat: lat, lng: lng)
                    }
                }
                saveButton.isHidden = true
                nameText.isEnabled = false
                commentText.isEnabled = false
            } catch {
                print("Error")
            }
        } else {
            nameText.text = ""
            commentText.text = ""
            latitude = 0.0
            longitude = 0.0
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
            gestureRecognizer.minimumPressDuration = 3
            mapView.addGestureRecognizer(gestureRecognizer)
        }
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
        focusLocation(lat: locations[0].coordinate.latitude, lng: locations[0].coordinate.longitude)
    }
    
    func focusLocation(lat: Double, lng: Double){
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
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
                    self.navigationController?.popViewController(animated: true)
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

