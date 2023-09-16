//
//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//

import UIKit

class InputViewController: UIViewController {
    
    
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    
    
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        personsSmallPhotoImageView.image = smallImage!
        personsBigPhotoImageView.image = bigImage!
        
    }
    
    @IBAction func postAction(_ sender: Any) {
        guard let personDict = createPersonDict() else {
            return
        }
        
        var personsArray = fetchPersonsArray()
        personsArray.append(personDict)
        
        savePersonsArray(personsArray)
        
        self.navigationController?.popViewController(animated: true)
    }

    // ユーザー入力からデータを取得する関数
    func createPersonDict() -> [String: Any]? {
        guard let personName = personNameTextField.text,
              let smallImageData = personsSmallPhotoImageView.image?.jpegData(compressionQuality: 0.01),
              let bigImageData = personsBigPhotoImageView.image?.jpegData(compressionQuality: 0.01) else {
            return nil
        }
        
        var personDict: [String: Any] = [
            "personName": personName,
            "smallImage": smallImageData,
            "bigImage": bigImageData,
            "comments": []
        ]
        
        return personDict
    }

    // UserDefaultsからpersonsArrayを取得する関数
    func fetchPersonsArray() -> [[String: Any]] {
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            return savedPersonsArray
        } else {
            return []
        }
    }

    // personsArrayに新しいデータを追加し、再び保存する関数
    func savePersonsArray(_ personsArray: [[String: Any]]) {
        UserDefaults.standard.setValue(personsArray, forKey: "personsArray")
    }

    
}
