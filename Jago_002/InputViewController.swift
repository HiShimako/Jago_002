//
//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//

import UIKit
//import FirebaseDatabase
//import FirebaseStorage

class InputViewController: UIViewController {
    
    var smallImage: UIImage?
    var bigImage: UIImage?
    var personName: String?
    
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        personsPhotoImageView.image = smallImage!
        personsBigPhotoImageView.image = bigImage!
        
    }
    
    @IBAction func postAction(_ sender: Any) {
        
        //UserDefaults.standardに保存
        UserDefaults.standard.set(personNameTextField.text, forKey: "personName")
        if let savedPersonName = UserDefaults.standard.object(forKey: "personName") as? String {
            print(savedPersonName)
        }
        
        let smalldata = smallImage?.jpegData(compressionQuality: 0.1)
        UserDefaults.standard.set(smalldata, forKey: "smallImage")
        if let savedSmallImageData = UserDefaults.standard.object(forKey: "smallImage") as? Data {
            print("smallImage is saved with size: \(savedSmallImageData.count) bytes.")
        } else {
            print("smallImage data is not saved in UserDefaults.")
        }
        
        
        let bigdata = bigImage?.jpegData(compressionQuality: 0.1)
        UserDefaults.standard.set(bigdata, forKey: "bigImage")
        if let savedBigImageData = UserDefaults.standard.object(forKey: "bigImage") as? Data {
            print("bigImage is saved with size: \(savedBigImageData.count) bytes.")
        } else {
            print("bigImage data is not saved in UserDefaults.")
        }
        
    }
        
//        let personListDB = Database.database().reference().child("personList").childByAutoId()
//
//        //                ストレージサーバーのURLを取得
//        let storage = Storage.storage().reference(forURL: "gs://jagoapp-5f1be.appspot.com")
//
//
//        /*** 投稿コンテンツ一連 ***/
//        //        投稿コンテンツ用のフォルダを作成
//        let contentsKey = personListDB.child("Contents").childByAutoId().key
//        let contentsImageRef = storage.child("Contents").child("\(String(describing: contentsKey!)).jpg")
//
//        //        データ型の変数を用意しておく
//        var personImageData:Data = Data()
//
//        //        画像があったら用意した変数（データ型）にサイズ1/100でいれる
//        if personsPhotoImageView.image != nil{
//            personImageData = (personsPhotoImageView.image?.jpegData(compressionQuality: 0.01))!
//        }
//
        //        uploadTask.resume()
        
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
