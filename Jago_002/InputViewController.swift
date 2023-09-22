//
//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//
import UIKit

enum AnimationSet: String {
    case firstSet = "2_out00"
    case secondSet = "4_out00"
}

class InputViewController: UIViewController {
    
    // MARK: - Properties
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    @IBOutlet weak var selectBackGroundViewSegment: UISegmentedControl!
    @IBAction func selectBackGroundViewAction(_ sender: Any) {
        
    }
    @IBOutlet weak var backGroundView: UIView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let smallImage = smallImage {
            personsSmallPhotoImageView.image = smallImage
        }
        if let bigImage = bigImage {
            personsBigPhotoImageView.image = bigImage
        }
    }
    
    // MARK: - Actions
    @IBAction func postAction(_ sender: Any) {
        
        guard let personDict = createPersonDict() else { return }
        
        var personsArray = fetchPersonsArray()
        personsArray.append(personDict)
        
        savePersonsArray(personsArray)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    private func createPersonDict() -> [String: Any]? {
        guard let personName = personNameTextField.text,
              let smallImageData = personsSmallPhotoImageView.image?.jpegData(compressionQuality: 0.01),
              let bigImageData = personsBigPhotoImageView.image?.jpegData(compressionQuality: 0.01) else {
            return nil
        }
        let selectedIndex = selectBackGroundViewSegment.selectedSegmentIndex
        return [
            "personName": personName,
            "smallImage": smallImageData,
            "bigImage": bigImageData,
            "comments": [] as [[String: Any]],
            "backgroundViewIndex": selectedIndex
        ]
    }
    
    private func fetchPersonsArray() -> [[String: Any]] {
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            return savedPersonsArray
        }
        return []
    }
    
    private func savePersonsArray(_ personsArray: [[String: Any]]) {
        UserDefaults.standard.setValue(personsArray, forKey: "personsArray")
    }
}
