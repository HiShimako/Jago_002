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
    
    func personDictionary(personName: String, smallImage: UIImage, bigImage: UIImage) -> [String: Any]? {
        guard let smallImageData = smallImage.jpegData(compressionQuality: 0.1),
              let bigImageData = bigImage.jpegData(compressionQuality: 0.5) else {
            return nil
        }
        return [
            "personName": personName,
            "smallImage": smallImageData,
            "bigImage": bigImageData
        ]
    }
    
    @IBAction func postAction(_ sender: Any) {
            
            guard let personName = personNameTextField.text,
                  let smallImageData = personsSmallPhotoImageView.image?.jpegData(compressionQuality: 0.01),
                  let bigImageData = personsBigPhotoImageView.image?.jpegData(compressionQuality: 0.01) else {
                return
            }

            // 保存するディクショナリを作成
            let personDict: [String: Any] = [
                "personName": personName,
                "smallImage": smallImageData,
                "bigImage": bigImageData
            ]
            
            // 既存の配列を取得または新しい配列を初期化
            var personsArray: [[String: Any]]
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
                personsArray = savedPersonsArray
            } else {
                personsArray = []
            }
            
            // ディクショナリを配列に追加
            personsArray.append(personDict)
            
            // 更新された配列をUserDefaultsに保存
            UserDefaults.standard.setValue(personsArray, forKey: "personsArray")
        
        self.navigationController?.popViewController(animated: true)

    
    }
    
}
