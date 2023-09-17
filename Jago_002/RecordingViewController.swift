//
//  RecordingViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/13.
//

import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    
    var isRecording = false
    var w: CGFloat = 0
    var h: CGFloat = 0
    let d: CGFloat = 50
    let l: CGFloat = 28
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    @IBOutlet weak var textView: UITextView!
    
    var comment:[String:String]!
    var personsArray: [[String: Any]]!
    
    var receivedRow: Int!
    
    var receivedImageData: Data?
    
    var backGroundImageArray : [UIImage] = []

    
    @IBOutlet weak var recordingView: UIImageView!
    //    var audioEngine: AVAudioEngine!
    //    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var selectedImage: UIImage?
//    var selectedCellIndexPath: IndexPath?
    var comments: [[String:Any]] = []
    
    //    func instantiateAndPresentRecordingVC(with imageData: Data?, at indexPath: IndexPath) {
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        if let RecordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingVC") as? RecordingViewController {
    ////            RecordingVC.receivedImageData = imageData
    //            RecordingVC.receivedIndexPath = indexPath // ここでindexPathを渡す
    //            RecordingVC.audioEngine = self.audioEngine
    //            self.present(RecordingVC, animated: true, completion: nil)
    //        }
    //    }

    @IBOutlet weak var backGroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        while let backGoundImage = UIImage(named: "2_out00\(backGroundImageArray.count+1)") {
            backGroundImageArray.append(backGoundImage)
        }
        // 配列を使ったアニメーションの配置
        backGroundView.animationImages = backGroundImageArray
        // イメージを切り替える間隔
        backGroundView.animationDuration = 1.5
        // アニメーションの繰り返し回数
        backGroundView.animationRepeatCount = 20
        // アニメーションを開始
        backGroundView.startAnimating()
//
//        UIView.animate(withDuration: 1, delay: 0, animations: { [weak self] in
//            // ここでViewの色の変更を行う
//            self?.view.backgroundColor = UIColor.green
//        })
        audioEngine = AVAudioEngine()
        textView.text = ""
        
        //下記関数は不要だけど参照されているから消せない状態
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            self.personsArray = savedPersonsArray
            self.comments = self.personsArray[receivedRow]["comments"] as! [[String : Any]]
            print("☺️☺️☺️☺️☺️☺️")
            debugPrint(comments)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let imageData = personsArray[receivedRow]["bigImage"] as? Data,
           let image = UIImage(data: imageData) {
            recordingView.image = image
        }
        try! startLiveTranscription()
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
     
                }
            }
        }
    }
    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        textView.text = ""
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {
            return
        }
        recognitionReq.shouldReportPartialResults = true
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // マイク入力の設定
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("\(error)")
            } else {
                DispatchQueue.main.async {
                    self.textView.text = result?.bestTranscription.formattedString
                    //                    let textData = textView.text,
                }
            }
        })
    }
    //    func stopLiveTranscription() {
    //        audioEngine.stop()
    //        audioEngine.inputNode.removeTap(onBus: 0)
    //        recognitionReq?.endAudio()
    //    }
    
    @IBAction func stopRecording(_ sender: Any) {
        stopLiveTranscription()
        
        comments.append(createCommentDict())
        personsArray[receivedRow].updateValue(comments, forKey: "comments")
        
        // 保存したい
        UserDefaults.standard.set(personsArray, forKey: "personsArray")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // ユーザー入力からデータを取得する関数
    func createCommentDict() -> [String: Any] {
        // 現在の日時を取得
        let currentDate = Date()
        
        // 日時を文字列に変換するためのフォーマッターを設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // 日時を文字列に変換
        let currentDateString = formatter.string(from: currentDate)
        
        let commentDict: [String: Any] = [
            "time": currentDateString,
            "comment": textView.text!,
        ]
        
        return commentDict
    }
    
}


//import Foundation
//
//// コメントを設定
//let comment = "これはコメントです"
//
//// 辞書型の配列に現在の日時とコメントを追加
//var array: [[String: String]] = []
//let dictionary = ["time": currentDateString, "comment": comment]
//array.append(dictionary)
//
//print(array)




// UserDefaultsからcommentsArrayを取得する関数
func fetchCommentsArray() -> [[String: Any]] {
    if let savedCommentsArray = UserDefaults.standard.array(forKey: "commentsArray") as? [[String: Any]] {
        return savedCommentsArray
    } else {
        return []
    }
}

// commentsArrayに新しいデータを追加し、再び保存する関数
func saveCommentsArray(_ commentsArray: [[String: Any]]) {
    UserDefaults.standard.setValue(commentsArray, forKey: "commentsArray")
}

