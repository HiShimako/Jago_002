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
    
    var personsArray: [[String: Any]]!
    var receivedIndexPath: IndexPath!
    var receivedImageData: Data?
    
    @IBOutlet weak var recordingView: UIImageView!
    //    var audioEngine: AVAudioEngine!
    //    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var selectedImage: UIImage?
    var selectedCellIndexPath: IndexPath?
    
    
    //    func instantiateAndPresentRecordingVC(with imageData: Data?, at indexPath: IndexPath) {
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        if let RecordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingVC") as? RecordingViewController {
    ////            RecordingVC.receivedImageData = imageData
    //            RecordingVC.receivedIndexPath = indexPath // ここでindexPathを渡す
    //            RecordingVC.audioEngine = self.audioEngine
    //            self.present(RecordingVC, animated: true, completion: nil)
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        textView.text = ""
        
        //下記関数は不要だけど参照されているから消せない状態
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            self.personsArray = savedPersonsArray
        } else {
            print("No personsArray found in UserDefaults.")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let imageData = personsArray[selectedCellIndexPath!.row]["bigImage"] as? Data,
           let image = UIImage(data: imageData) {
            recordingView.image = image
            print("Image was set successfully")
        } else {
            print("receivedImageData is nil")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //      w = baseView.frame.size.width
        //      h = baseView.frame.size.height
        
        //        initRoundCorners()
        //        showStartButton()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
                    //                    self.recordButton.isEnabled = false
                    //                    self.recordButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
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
        
        if isRecording {
            UIView.animate(withDuration: 0.2) {
                //                self.showStartButton()
            }
            stopLiveTranscription()
        } else {
            UIView.animate(withDuration: 0.2) {
                //                self.showStopButton()
            }
            try! startLiveTranscription()
        }
        isRecording = !isRecording
        
        
        //        func initRoundCorners(){
        //          recordButton.layer.masksToBounds = true
        //
        //          baseView.layer.masksToBounds = true
        //          baseView.layer.cornerRadius = 10
        //          baseView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        //
        //          outerCircle.layer.masksToBounds = true
        //          outerCircle.layer.cornerRadius = 31
        //          outerCircle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //
        //          innerCircle.layer.masksToBounds = true
        //          innerCircle.layer.cornerRadius = 29
        //          innerCircle.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        //        }
        
        //        func showStartButton() {
        //          recordButton.frame = CGRect(x:(w-d)/2,y:(h-d)/2,width:d,height:d)
        //          recordButton.layer.cornerRadius = d/2
        //        }
        //
        //        func showStopButton() {
        //          recordButton.frame = CGRect(x:(w-l)/2,y:(h-l)/2,width:l,height:l)
        //          recordButton.layer.cornerRadius = 3.0
        //        }
        
//        self.navigationController?.popViewController(animated: true)
    }
    
}


