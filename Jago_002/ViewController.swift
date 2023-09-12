//
//  ViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Kingfisher//urlから画像を読み込んできて表示してくれるライブラリ
import FirebaseDatabase
import Photos

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var personListTableView: UITableView!
    
    var contentImageString = String()
    var contentsArray = [Contents]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()      /* self追加 */
        personListTableView.delegate = self
        personListTableView.dataSource = self
        
    }

    @IBAction func addPerson(_ sender: Any) {
        showAlert()
    }
    
    
    /* Fixで自動的に追加 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentsArray.count//セクションの行の数
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//セクションそのものの数
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

 
        let cell = personListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //        コンテンツ
        //        タグで管理
        //        投稿画像
        let contentImageView = cell.viewWithTag(4) as! UIImageView
        contentImageView.kf.setImage(with: URL(string: contentsArray[indexPath.row].contentImageString))
        
        return cell
   }


    //    カメラ立ち上げメソッド
    func checkCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        
        //        カメラ利用可能かチェック
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
            
        }
    }
    
    //    フォトライブラリの使用
    func checkAlbam() {
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        //        フォトライブラリのチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
        }
    }
    
    //    アラートでカメラorアルバムの選択をさせる
    func showAlert(){
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.checkCamera()
        }
        
        let albamAction = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.checkAlbam()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        
        alertController.addAction(cameraAction)
        alertController.addAction(albamAction)
        alertController.addAction(cancelAction)
        present(alertController,animated: true,completion: nil)
    }
    
    //    キャンセル時の処理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as! UIImage
        let originalImage = info[.originalImage] as! UIImage
        
        //        ナビゲーションを用いて画面遷移
        let editPostVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        
        editPostVC.smallImage = selectedImage
        editPostVC.bigImage = originalImage
        
        self.navigationController?.pushViewController(editPostVC, animated: true)
        
        //        ピッカーを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
}

