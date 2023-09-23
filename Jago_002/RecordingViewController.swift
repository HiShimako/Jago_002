import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    var isRecording = false
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    @IBOutlet weak var recordingView: UIImageView!
    @IBOutlet weak var backGroundView: UIImageView!

    var personsArray: [[String: Any]]!
    var receivedRow: Int?
    var comments: [[String: Any]] = []
    var bestTranscriptionString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] ?? []
        audioEngine = AVAudioEngine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let receivedRow = receivedRow,
           let imageData = personsArray[receivedRow]["bigImage"] as? Data,
           receivedRow < personsArray.count {
            recordingView.image = UIImage(data: imageData)
        }
        try? startLiveTranscription()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        bestTranscriptionString = ""
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else { return }
        recognitionReq.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, _) in
            recognitionReq.append(buffer)
        }

        try audioEngine.start()
        recognizer.recognitionTask(with: recognitionReq) { (result, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                self.bestTranscriptionString = result?.bestTranscription.formattedString
            }
        }
    }

    @IBAction func stopRecording(_ sender: Any) {
        stopLiveTranscription()
        if let receivedRow = receivedRow {
            let commentDict = createCommentDict(comment: bestTranscriptionString ?? "")
            if let existingComments = personsArray[receivedRow]["comments"] as? [[String: Any]] {
                comments = existingComments
            }
            comments.append(commentDict)
            personsArray[receivedRow].updateValue(comments, forKey: "comments")
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
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
