//
//  ViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Photos

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var personListTableView: UITableView!
    
    var personsArray: [[String: Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personListTableView.delegate = self
        personListTableView.dataSource = self
        
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            personsArray = savedPersonsArray
        } else {
            personsArray = []
        }
        
    }
    /* Fixで自動的に追加 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personsArray.count//セクションの行の数
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//セクションそのものの数
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let imageView = cell.viewWithTag(4) as? UIImageView {
            if let data = personsArray[indexPath.row]["smallImage"] as? Data {
                let image = UIImage(data: data)
                imageView.image = image
            } else {
                imageView.image = nil // もしくはデフォルトの画像
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 2 / 3
    }
    
    @IBAction func addPerson(_ sender: Any) {
        showAlert()
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
