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
    
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var name = ""
    var id = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        
        if name != "" {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "id= %@", id.uuidString)
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "title") as? String {
                        nameText.text = name
                    }
                    if let comment = result.value(forKey: "subtitle") as? String {
                        commentText.text = comment
                    }
                    if let lat = result.value(forKey: "latitude") as? Double, let lng = result.value(forKey: "longitude") as? Double {
                        longitude = lng
                        latitude = lat
                        showLocation(lat: lat, lng: lng)
                        showPin(lat: lat, lng: lng)
                    }
                    
                    nameText.isEnabled = false
                    commentText.isEnabled = false
                    saveButton.isHidden = true
                }
            } catch {
                print("Error")
            }
            
        } else {
            configuringLocation()
            addGestureRecognizerToView()
            addLongPressGestureToMapView()
        }
        
    }
    
    func addLongPressGestureToMapView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(sender:)))
        gesture.minimumPressDuration = 3
        mapView.addGestureRecognizer(gesture)
    }
    
    func configuringLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func addGestureRecognizerToView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func chooseLocation(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchLocation = sender.location(in: mapView)
            let coordinates = mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
            
            showPin(lat: coordinates.latitude, lng: coordinates.longitude)
            
            longitude = coordinates.longitude
            latitude = coordinates.latitude
        }
    }
    
    func showPin(lat: Double, lng: Double){
        let annotation = MKPointAnnotation()
        annotation.title = nameText.text
        annotation.subtitle = commentText.text
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        showLocation(lat: locations[0].coordinate.latitude, lng: locations[0].coordinate.longitude)
    }
    
    func showLocation(lat: Double, lng: Double) {
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(latitude, forKey: "latitude")
        newPlace.setValue(longitude, forKey: "longitude")
        
        do {
            try context.save()
            print("Success")
            let alert = UIAlertController(title: "Success", message: "Place added successfuly", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okButton)
            self.present(alert, animated: true)
        } catch {
            print("Error")
        }
    }
}

