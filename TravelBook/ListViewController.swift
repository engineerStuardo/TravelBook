//
//  ListViewController.swift
//  TravelBook
//
//  Created by Italo Stuardo on 30/3/23.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    var selectedTitle = ""
    var selectedId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let rightButon = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlace))
        navigationItem.setRightBarButton(rightButon, animated: true)
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    @objc func addPlace() {
        selectedTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func getData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                titleArray.removeAll()
                idArray.removeAll()
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch {
            print("Error fetching data from CoreData")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = titleArray[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTitle = titleArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destination = segue.destination as! ViewController
            destination.placeTitle = selectedTitle
            destination.placeId = selectedId
        }
    }
}
