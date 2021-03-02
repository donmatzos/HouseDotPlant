//
//  PlandAddController.swift
//  HouseDotPlant
//
//  Created by Matthias Girkinger on 23.02.21.
//

import UIKit

class PlantAddController: UIViewController {
    //MARK:- Member Variables
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var roomIndex = 0
    
    //MARK:- Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var wateringCycleTextField: UITextField!
    @IBOutlet weak var wateringDatePicker: UIDatePicker!
    @IBOutlet weak var addImageButton: UIButton!
    
    
    //MARK:- Actions
    @IBAction func plantPhotoButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Photo", message: "Choose an image from your camera or gallery.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.delegate = self
            vc.allowsEditing = true
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func clickedGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func clickedCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    @IBAction func doneClicked(_ sender: Any) {
        if let viewContext = self.appDelegate?.persistentContainer.viewContext {
            let plant = Plant(context: viewContext)
            plant.name = plantNameTextField.text!
            plant.img = Data((imageView.image?.pngData() ?? UIImage(named: "no-photo")!.pngData())!)
            plant.roomIndex = Int32(roomIndex)
            print("\(plant.roomIndex)")
            plant.lastWatered = wateringDatePicker.date
            var watCyc: Int = Int(wateringCycleTextField.text!) ?? 1
            if watCyc < 1 {
                watCyc = 1
            } else if watCyc > 50 {
                watCyc = 50
            }
            plant.wateringCycle = Int32(watCyc)

            self.appDelegate?.saveContext()
        }
        
    }
    
    //MARK:- View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        wateringDatePicker.preferredDatePickerStyle = .wheels
        plantNameTextField.text = ""
        wateringCycleTextField.text = "1"
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 5
        addImageButton.layer.cornerRadius = 5
    }

}

//MARK:- Image Picker- and Navigation Controller Delegate
extension PlantAddController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print("\(info)")
        let key = UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")
        if let image = info[key] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
