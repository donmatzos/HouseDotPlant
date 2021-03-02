//
//  PlantDetailView.swift
//  HouseDotPlant
//
//  Created by Matthias Girkinger on 25.02.21.
//

import UIKit
import CoreData

class PlantDetailView: UIViewController {
    //MARK:- Member Variables
    var indexArray = [0, 0]
    var roomArray: [Room] = []
    var plantArray: [[Plant]] = Array<Array<Plant>>()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    //MARK:- Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantWaterinCycle: UILabel!
    @IBOutlet weak var nextWateringDate: UILabel!
    
    //MARK:- View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
//        let backgroundImage = UIImageView(image: UIImage(named: "detailScreen"))
//        backgroundImage.contentMode = .scaleAspectFill
//        self.view.insertSubview(backgroundImage, at: 0)
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = UIColor.white.cgColor
        //TODO - Add describing labels
        plantName.textColor = UIColor.white
        plantWaterinCycle.textColor = UIColor.white
        nextWateringDate.textColor = UIColor.white
        readRooms()
        let plantsReqetsed = readPlants()
        for plant in plantsReqetsed {
            for _ in roomArray {
                plantArray.append([Plant]())
            }
            if !plantsReqetsed.isEmpty {
                if plantArray[Int(plant.roomIndex)].isEmpty {
                    plantArray.append([Plant()])
                }
                plantArray[Int(plant.roomIndex)].append(plant)
            }
        }
        let plantToDisplay = plantArray[indexArray[0]][indexArray[1]]
        var dateForNextWatering = plantToDisplay.lastWatered
        var dayComponents = DateComponents()
        dayComponents.day = Int(plantToDisplay.wateringCycle)
        dateForNextWatering = Calendar.current.date(byAdding: dayComponents, to: dateForNextWatering!)
        self.view.backgroundColor = UIColor.systemGreen
        imageView.backgroundColor = UIColor.systemBackground
        imageView.image = UIImage(data: plantToDisplay.img!)
        plantName.text = plantToDisplay.name
        plantWaterinCycle.text = "Watering cycle: \(plantToDisplay.wateringCycle) days"
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd.MM."
        nextWateringDate.text = "Needs water: \(formatter.string(from: dateForNextWatering!))"
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
