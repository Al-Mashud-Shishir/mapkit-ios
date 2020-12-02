//
//  TableViewController.swift
//  TravelBook-MapKitExample
//
//  Created by Maddi on 2/12/20.
//

import UIKit
import CoreData

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var names = [String]()
    var ids = [UUID]()
    var chosenId:UUID?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewPlace))
        // Do any additional setup after loading the view.
    }
    @objc func addNewPlace(){
        performSegue(withIdentifier: "mapView", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        getStoredData()
    }
    func getStoredData(){
        names.removeAll()
        ids.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    names.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    ids.append(id)
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error reading data")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenId = ids[indexPath.row]
        performSegue(withIdentifier: "detailsView", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsView"{
            let detailsViewController = segue.destination  as! DetailsViewController
            detailsViewController.chosenId = chosenId
        }
    }

}
