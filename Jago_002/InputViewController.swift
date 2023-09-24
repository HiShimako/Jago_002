//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//
import UIKit

enum AnimationSet: String {
    case caseOne = "2_out00"
    case caseTwo = "4_out00"
}

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    @IBOutlet weak var selectBackGroundViewSegment: UISegmentedControl!
    @IBOutlet weak var backGroundView: UIImageView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialStates()
    }
    
    // MARK: - Initialization Methods
    private func setupInitialStates() {
        setupInitialImages()
        setupInitialAnimation()
        setupSegmentedControl()
    }
    
    private func setupInitialImages() {
        personsSmallPhotoImageView.image = smallImage
        personsBigPhotoImageView.image = bigImage
    }
    
    private func setupInitialAnimation() {
        applyAnimationBasedOnSegmentIndex(selectBackGroundViewSegment.selectedSegmentIndex)
    }
    
    private func setupSegmentedControl() {
        if let originalImage1 = UIImage(named: "\(AnimationSet.caseOne.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
            selectBackGroundViewSegment.setImage(originalImage1, forSegmentAt: 0)
        }
        
        if let originalImage2 = UIImage(named: "\(AnimationSet.caseTwo.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
            selectBackGroundViewSegment.setImage(originalImage2, forSegmentAt: 1)
        }
    }
    
    // MARK: - Actions
    @IBAction func selectBackGroundViewAction(_ sender: Any) {
        applyAnimationBasedOnSegmentIndex(selectBackGroundViewSegment.selectedSegmentIndex)
    }
    
    @IBAction func postAction(_ sender: Any) {
        guard let personDict = createPersonDict() else { return }
        saveNewPerson(personDict)
        printSavedPersons() 
        navigationController?.popViewController(animated: true)
    }
    @IBAction func editPersonImageTapped(_ sender: Any) {
        selectImageUtility.showAlert(self)
    }
    
    // MARK: - Helper Functions
    private func applyAnimationBasedOnSegmentIndex(_ index: Int) {
        let animationSet = (index == 0) ? AnimationSet.caseOne : AnimationSet.caseTwo
        BackGroundAnimationUtility.applyAnimation(on: backGroundView, withPrefix: animationSet.rawValue)
    }
    
    private func createPersonDict() -> [String: Any]? {
        guard let personName = personNameTextField.text,
              let smallImageData = personsSmallPhotoImageView.image?.jpegData(compressionQuality: 0.01),
              let bigImageData = personsBigPhotoImageView.image?.jpegData(compressionQuality: 0.01) else {
            return nil
        }
        
        return [
            "personName": personName,
            "smallImage": smallImageData,
            "bigImage": bigImageData,
            "comments": [] as [[String: Any]],
            "backgroundViewIndex": selectBackGroundViewSegment.selectedSegmentIndex
        ]
    }
    
    private func saveNewPerson(_ personDict: [String: Any]) {
        var personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] ?? []
        personsArray.append(personDict)
        UserDefaults.standard.setValue(personsArray, forKey: "personsArray")
    }
    private func printSavedPersons() {
        if let personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            print("Saved Persons:")
            for (index, personDict) in personsArray.enumerated() {
                if let name = personDict["personName"] as? String,
                   let backgroundViewIndex = personDict["backgroundViewIndex"] as? Int {
                    print("Person \(index+1): \(name), BackgroundViewIndex: \(backgroundViewIndex)")
                }
            }
        } else {
            print("No persons saved in UserDefaults.")
        }
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            
            smallImage = selectedImage
            bigImage = selectedImage
            
            personsSmallPhotoImageView.image = smallImage
            personsBigPhotoImageView.image = bigImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BackGroundAnimationUtility
struct BackGroundAnimationUtility {
    static func applyAnimation(on view: UIView, withPrefix prefix: String) {
        guard let imageView = view as? UIImageView,
              let animationImages = fetchAnimationImages(withPrefix: prefix), !animationImages.isEmpty else {
            return
        }
        
        imageView.animationImages = animationImages
        imageView.animationDuration = 1.0
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }
    
    private static func fetchAnimationImages(withPrefix prefix: String) -> [UIImage]? {
        var backGroundImageArray: [UIImage] = []
        var index = 1
        while let image = UIImage(named: "\(prefix)\(index)") {
            backGroundImageArray.append(image)
            index += 1
        }
        return backGroundImageArray.isEmpty ? nil : backGroundImageArray
    }
}

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

