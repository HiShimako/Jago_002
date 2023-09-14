//
//  ViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Photos
import Speech

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP")) // 日本語設定
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var personsArray: [[String: Any]] = []
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let cellData = personsArray[indexPath.row]
            if let imageData = cellData["bigImage"] as? Data, let image = UIImage(data: imageData) {
                performSegue(withIdentifier: "showRecordingViewController", sender: (image, indexPath))
            }
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showRecordingViewController", let vc = segue.destination as? RecordingViewController, let (image, indexPath) = sender as? (UIImage, IndexPath) {
             vc.selectedImage = image
             vc.selectedCellIndexPath = indexPath
         }
     }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer?.delegate = self
        // 最初に音声認識の権限を求める
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized: break // 権限がある場合、何もしない
            default: print("Speech recognition authorization not granted") // 権限がない場合、エラーメッセージを表示
            }
        }
        
        
        
        personListTableView.delegate = self
        personListTableView.dataSource = self
        
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            personsArray = savedPersonsArray
        } else {
            personsArray = []
        }
        
    }
    
    @IBAction func tappedSmallImage(_ sender: Any) {
        
        print("tappedSmallImage was called")
        
        // sender（ここではジェスチャー）をUITapGestureRecognizer型にダウンキャスト
        guard let gesture = sender as? UITapGestureRecognizer,
              // ジェスチャーのターゲットとなったビュー（UIImageView）を取得
              let tappedImageView = gesture.view as? UIImageView,
              // UIImageViewの親ビュー（ここではUITableViewCell）を取得
              let cell = tappedImageView.superview?.superview as? UITableViewCell,
              // そのセルのインデックスパスを取得
              let indexPath = personListTableView.indexPath(for: cell) else { return }

        // 対応するインデックスパスのデータから、大きな画像のデータを取得
        let selectedImageData = personsArray[indexPath.row]["bigImage"] as? Data

        // Main.storyboardを取得
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // "RecordingVC"というIDを持つビューコントローラを取得し、RecordingViewControllerとしてダウンキャスト
        if let RecordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingVC") as? RecordingViewController {
            // 画像データをRecordingViewControllerに渡す
            RecordingVC.receivedImageData = selectedImageData
            
            // ViewControllerのaudioEngineをRecordingViewControllerに渡す
            RecordingVC.audioEngine = self.audioEngine
            
            // RecordingViewControllerをモーダル表示
            self.present(RecordingVC, animated: true, completion: nil)
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
    }
    
    @IBOutlet weak var personListTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        
        if let perArray = userDefaults.object(forKey: "personsArray") as? [[String: Any]] {
            personsArray = perArray
        }
        //tableViewを更新
        personListTableView.reloadData()
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
        return self.view.frame.height * 1 / 3
    }
    
    
    
    
    @IBAction func addPerson(_ sender: Any) {
        showAlert()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //taskArray内のindexPathのrow番目をremove（消去）する
            personsArray.remove(at: indexPath.row)
            
            //再びアプリ内に消去した配列を保存
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            
            //tableViewを更新
            tableView.reloadData()
        }
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
