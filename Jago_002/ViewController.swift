//
//  ViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Photos
import Speech
import Foundation


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate, UIGestureRecognizerDelegate, CatchProtocol  {
    
    

    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var personsArray: [[String: Any]] = []
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showRecordingViewController", let vc = segue.destination as? RecordingViewController, let (image, indexPath) = sender as? (UIImage, IndexPath) {
//            vc.selectedImage = image
//            vc.selectedCellIndexPath = indexPath
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpeechRecognition()
        setupTableView()
        loadSavedPersons()
    }

    func setupSpeechRecognition() {
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized: break // 権限がある場合、何もしない
            default: print("Speech recognition authorization not granted")
            }
        }
    }

    func setupTableView() {
        personListTableView.delegate = self
        personListTableView.dataSource = self
    }

    func loadSavedPersons() {
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            personsArray = savedPersonsArray
        } else {
            personsArray = []
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        
        if let perArray = userDefaults.object(forKey: "personsArray") as? [[String: Any]] {
            personsArray = perArray
        }
        //tableViewを更新
        personListTableView.reloadData()
    }

    @IBOutlet weak var personListTableView: UITableView!

    // MARK: テーブルビューデータ系

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonsTableViewCell
        
        if let data = personsArray[indexPath.row]["smallImage"] as? Data {
            let image = UIImage(data: data)
            cell.personImageView.image = image

        }
        cell.delegate = self
        cell.smallImageButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row

        
        return cell
    }

    func tapSmallImage(id: Int) {
        let VC = self.storyboard?.instantiateViewController(identifier: "RecordingVC") as! RecordingViewController
        VC.receivedRow = id
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func tapCommentButton(id: Int) {
        // RecordedViewControllerに移動する
        let VC = self.storyboard?.instantiateViewController(identifier: "RecordedViewController") as! RecordedViewController
        VC.receivedRow = id
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    @IBAction func tapComment(_ sender: UIButton) {
        debugPrint(sender)
    }
    // MARK: テーブルビュー動作系

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 1 / 3
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = personsArray[indexPath.row]
        if let imageData = cellData["bigImage"] as? Data, let image = UIImage(data: imageData) {
            performSegue(withIdentifier: "showRecordingViewController", sender: (image, indexPath))
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            personsArray.remove(at: indexPath.row)
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            tableView.reloadData()
        }
    }

    // MARK: 録音開始ボタンですること
    
    
    
    func tappedCommentButton(sender: UIButton) {
            print(sender)
    }
    
    func saveTextData(personName: String, textData: String) {
        let textDict: [String: Any] = [
            "personName": personName,
            "text": textData
        ]
        
        var textsArray = UserDefaults.standard.array(forKey: "textsArray") as? [[String: Any]] ?? []
        textsArray.append(textDict)
        UserDefaults.standard.set(textsArray, forKey: "textsArray")
    }
    
    func getCurrentTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }

    @IBAction func addPerson(_ sender: Any) {
        showAlert()
    }
    
    //　写真追加の関数
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
