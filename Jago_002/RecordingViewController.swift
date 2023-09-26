//  RecordingViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//
import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    
    // MARK: - Properties
    var isRecording = false
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - IBOutlets
    @IBOutlet weak var recordingView: UIImageView!
    @IBOutlet weak var backGroundView: UIImageView!
    
    // MARK: - Variables
    var personsArray: [[String: Any]]!
    var receivedRow: Int?
    var comments: [[String: Any]] = []
    var bestTranscriptionString: String?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize properties
        personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] ?? []
        audioEngine = AVAudioEngine()
        
        // Apply background animation based on selected index
        if let receivedRow = receivedRow,
           let backgroundViewIndex = personsArray[receivedRow]["backgroundViewIndex"] as? Int {
            let animationSet: AnimationSet
            switch backgroundViewIndex {
            case 0:
                animationSet = .case0
            case 1:
                animationSet = .case1
            case 2:
                animationSet = .case2
            case 3:
                animationSet = .case3
            case 4:
                animationSet = .case4
            default:
                animationSet = .case4
            }
            // Apply the background animation using the decided AnimationSet
            BackGroundAnimationUtility.applyAnimation(on: backGroundView, withPrefix: animationSet.rawValue)
        
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load recorded image if available
        if let receivedRow = receivedRow,
           let imageData = personsArray[receivedRow]["bigImage"] as? Data,
           receivedRow < personsArray.count {
            recordingView.image = UIImage(data: imageData)
        }
        
        // Start live transcription
        try? startLiveTranscription()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    // MARK: - Helper Functions
    
    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        // Cancel any existing recognition task
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Initialize new recognition request
        bestTranscriptionString = ""
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else { return }
        recognitionReq.shouldReportPartialResults = true
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Configure input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, _) in
            recognitionReq.append(buffer)
        }
        
        // Start audio engine and recognition task
        try audioEngine.start()
        recognizer.recognitionTask(with: recognitionReq) { (result, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                self.bestTranscriptionString = result?.bestTranscription.formattedString
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func stopRecording(_ sender: Any) {
        stopLiveTranscription()
        
        // Save transcription as comment if available
        if let receivedRow = receivedRow {
            let commentDict = createCommentDict(comment: bestTranscriptionString ?? "")
            
            // Fetch existing comments and append new one
            if let existingComments = personsArray[receivedRow]["comments"] as? [[String: Any]] {
                comments = existingComments
            }
            comments.append(commentDict)
            personsArray[receivedRow].updateValue(comments, forKey: "comments")
            
            // Update UserDefaults
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            
            // Navigate back
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createCommentDict(comment: String) -> [String: Any] {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let currentDateString = formatter.string(from: currentDate)
        return ["time": currentDateString, "comment": comment]
    }
}
