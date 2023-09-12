//
//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class InputViewController: UIViewController {
    
    var smallImage: UIImage?
    var bigImage: UIImage?
    
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
        
        let timeLineDB = Database.database().reference().child("timeLine").childByAutoId()
        
        //                ストレージサーバーのURLを取得
        let storage = Storage.storage().reference(forURL: "gs://photoapp-849ee.appspot.com/")
        
        /*** 投稿コンテンツ一連 ***/
        //        投稿コンテンツ用のフォルダを作成
        let contentsKey = timeLineDB.child("Contents").childByAutoId().key
        let contentsImageRef = storage.child("Contents").child("\(String(describing: contentsKey!)).jpg")
        
        //        データ型の変数を用意しておく
        var contentImageData:Data = Data()
        
        //        画像があったら用意した変数（データ型）にサイズ1/100でいれる
        if personsPhotoImageView.image != nil{
            contentImageData = (personsPhotoImageView.image?.jpegData(compressionQuality: 0.01))!
        }
        
//        uploadTask.resume()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
