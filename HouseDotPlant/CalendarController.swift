//
//  CalendarController.swift
//  HouseDotPlant
//
//  Created by Matthias Girkinger on 22.02.21.
//
import FSCalendar
import UIKit
import CoreData

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    //MARK:- Member Variables
    var dateWithEvent = [String]()
    var eventArray = [[String]]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd.MM.yyyy"
        return formatter
    }()
    
    //MARK:- Outlets
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.appearance.todayColor = .systemGreen
        let plantsRequested = readPlants()
        for plant in plantsRequested {
            var dateForEvent = plant.lastWatered
            var dayComponents = DateComponents()
            dayComponents.day = Int(plant.wateringCycle)
            dateForEvent = Calendar.current.date(byAdding: dayComponents, to: dateForEvent!)
            dateWithEvent.append(self.dateFormatter.string(from: dateForEvent!))
        }
        for _ in dateWithEvent {
            eventArray.append([String]())
        }
        var counter = 0
        for plant in plantsRequested {
            var date = plant.lastWatered
            var dayComponents = DateComponents()
            dayComponents.day = Int(plant.wateringCycle)
            date = Calendar.current.date(byAdding: dayComponents, to: date!)
            let dateString = self.dateFormatter.string(from: date!)
            if dateWithEvent[counter] == dateString {
                eventArray[counter].append("Water \(plant.name!)")
            }
            counter += 1
        }
        print("\(dateWithEvent)")
        calendar.delegate = self
        calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendar.reloadData()
        tableView.reloadData()
    }
    
    //MARK:- Calendar Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd-MM-YYYY"
        let string = formatter.string(from: date)
        print("\(string)")
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        if self.dateWithEvent.contains(dateString) {
            return 1
        }
        return 0
    }
    
    //MARK:- Core Data request
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
extension CalendarController: UITableViewDelegate {
    
}

extension CalendarController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !eventArray.isEmpty {
            if !eventArray[section].isEmpty {
                return eventArray[section].count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !eventArray[indexPath.section].isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
            cell.textLabel?.text = eventArray[indexPath.section][indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        cell.textLabel?.text = ""
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !dateWithEvent.isEmpty {
            return dateWithEvent.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateWithEvent[section]
    }
}
