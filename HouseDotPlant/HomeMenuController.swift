//
//  HomeMenuController.swift
//  HouseDotPlant
//
//  Created by Matthias Girkinger on 22.02.21.
//

import UIKit
import CoreData

class HomeMenuController: UIViewController {
    //MARK:- Member Variables
    var roomArray: [Room] = []
    var plantArray: [[Plant]] = Array<Array<Plant>>()
    var selectedIndex = 0
    var detailPlantIndices: [Int] = []
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var addRoomOutlet: UIButton!
    @IBOutlet weak var addPlantOutlet: UIButton!
    
    //MARK:- Actions
    @IBAction func addRoomBtn(_ sender: Any) {
        print("room tapped")
        //Cancel handler for quitting action
        let cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Room", message: "Enter room name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })

        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = alert!.textFields![0] as UITextField
            if let viewContext = self.appDelegate?.persistentContainer.viewContext {
                let room = Room(context: viewContext)
                room.name = textField.text!
                self.plantArray.append([Plant]())
                self.roomArray.append(room)
                self.appDelegate?.saveContext()
            }
            print("\(self.roomArray)")
            self.tableView.reloadData()
        }))
        
        //Add cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func addPlantBtn(_ sender: Any) {
        print("plant tapped")
        var optionArray: [UIAlertAction] = []
        let optionMenu = UIAlertController(title: nil, message: "Choose Room", preferredStyle: .actionSheet)
        var counter = 0
        for room in roomArray {
            let option = UIAlertAction(title: "\(room.name!)", style: .default, handler: { action in
                self.selectedIndex = optionMenu.actions.firstIndex(of: action)!
                self.performSegue(withIdentifier: "addPlantSegue", sender: nil)
            })
            counter += 1
            optionArray.append(option)
        }
        optionArray.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        for op in optionArray {
            optionMenu.addAction(op)
        }
        self.present(optionMenu, animated: true)
    }
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    //MARK:- View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backgroundColor = UIColor.systemGreen
        navigationBar.barTintColor = UIColor.systemGreen
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        addRoomOutlet.layer.cornerRadius = 5
        addPlantOutlet.layer.cornerRadius = 5
        readRooms()
        let plantsRequested = readPlants()
        for plant in plantsRequested {
            for _ in roomArray {
                plantArray.append([Plant]())
            }
            if !plantsRequested.isEmpty {
                if plantArray[Int(plant.roomIndex)].isEmpty {
                    plantArray.append([Plant()])
                }
                plantArray[Int(plant.roomIndex)].append(plant)
            }
            //print("\(plant.roomIndex)")
        }
        tableView.reloadData()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    //MARK:- Core Data requests
    func readRooms() {
        let request = NSFetchRequest<Room>(entityName: "Room")
        if let context = self.appDelegate?.persistentContainer.viewContext {
            let rooms = try? context.fetch(request)
            roomArray = rooms ?? []
        }
    }
    
    func readPlants() -> [Plant] {
        let request = NSFetchRequest<Plant>(entityName: "Plant")
        var sortArray = [Plant]()
        if let context = self.appDelegate?.persistentContainer.viewContext {
            let plants = try? context.fetch(request)
            sortArray = plants!
            return sortArray
        }
        return sortArray
    }
    
}

//MARK:- Table View Delegate + Data Source
extension HomeMenuController: UITableViewDelegate {
    
}

extension HomeMenuController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !plantArray.isEmpty {
            if !plantArray[section].isEmpty {
                return plantArray[section].count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !plantArray[indexPath.section].isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
            cell.textLabel?.text = plantArray[indexPath.section][indexPath.row].name
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        cell.textLabel?.text = ""
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !roomArray.isEmpty {
            return roomArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView,
                       titleForHeaderInSection section: Int) -> String? {
        return roomArray[section].name
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let plant = plantArray[indexPath.section][indexPath.row]
        if editingStyle == .delete {
            managedContext.delete(plant as NSManagedObject)
            plantArray[indexPath.section].remove(at: indexPath.row)
            do {
                try managedContext.save()
            } catch
            let error as NSError {
                print("Could not save. \(error),\(error.userInfo)")
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !detailPlantIndices.isEmpty {
            detailPlantIndices = []
        }
        print(indexPath.section)
        detailPlantIndices.append(indexPath.section)
        print(indexPath.row)
        detailPlantIndices.append(indexPath.row)
        performSegue(withIdentifier: "detailPlantSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlantSegue" {
            let vc = segue.destination as? PlantAddController
            vc?.roomIndex = selectedIndex
        }
        if segue.identifier == "detailPlantSegue" {
            let vc = segue.destination as? PlantDetailView
            vc?.indexArray = detailPlantIndices
            print("\(detailPlantIndices)")
        }
    }

}
