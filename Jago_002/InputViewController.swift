// InputViewController.swift
// Jago_002
//
// Created by user on 2023/09/11.

import UIKit
import RealmSwift

enum AnimationSet: String {
    case case0 = "2_out00"
    case case1 = "4_out00"
    case case2 = "6_out00"
    case case3 = "ezgif-frame-0"
    case case4 = "ezgif-frame-1"
    
    static var allCases: [AnimationSet] {
        return [.case0, .case1, .case2, .case3, .case4]
    }
    
    static func from(backgroundViewIndex: Int) -> AnimationSet? {
        guard backgroundViewIndex >= 0, backgroundViewIndex < allCases.count else {
            return nil
        }
        return allCases[backgroundViewIndex]
    }
    
}
//extension AnimationSet {
//    init?(backgroundViewIndex: Int) {
//        // リスト内のすべてのAnimationSetを取得
//        let allSets = AnimationSet.allCases
//
//        // インデックスの値を基に、適切なAnimationSetを取得
//        guard backgroundViewIndex >= 0, backgroundViewIndex < allSets.count else {
//            return nil
//        }
//
//        self = allSets[backgroundViewIndex]
//    }
//}

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    var isNewPerson: Bool = true
    var editingPersonID: Int?
    var backgroundViewIndex: Int?

    // MARK: - Outlets
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    @IBOutlet weak var selectBackGroundViewSegment: UISegmentedControl!
    @IBOutlet weak var backGroundView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialStates()
    }

    // MARK: - Initialization Methods
    private func setupInitialStates() {
        personsSmallPhotoImageView.image = smallImage
        personsBigPhotoImageView.image = bigImage

        if let personID = editingPersonID {
            // 編集モードの場合
            let realm = try! Realm()
            if let personToEdit = realm.object(ofType: Person.self, forPrimaryKey: personID) {
                // 対応するbackgroundViewIndexをRealmから取得し、セグメントコントロールにセットします。
                selectBackGroundViewSegment.selectedSegmentIndex = personToEdit.backgroundViewIndex
            }
        } else if selectBackGroundViewSegment.selectedSegmentIndex == UISegmentedControl.noSegment {
            // 新規追加モードの場合、セグメントコントロールの初期選択がなければ0をセットします。
            selectBackGroundViewSegment.selectedSegmentIndex = 0
        }

        AnimationUtility.applyAnimation(on: backGroundView, forBackgroundViewIndex: selectBackGroundViewSegment.selectedSegmentIndex)
         
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        for index in 0..<selectBackGroundViewSegment.numberOfSegments {
            if let animationSet = AnimationSet.from(backgroundViewIndex: index) {
                if let image = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
                    selectBackGroundViewSegment.setImage(image, forSegmentAt: index)
                }
            }
        }
    }
//    private func setupSegmentedControl() {
//        for index in 0..<selectBackGroundViewSegment.numberOfSegments {
//             if let animationSet = AnimationSet(backgroundViewIndex: index) {  // AnimationSet.from を AnimationSet.init? に変更
//                 if let image = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
//                     selectBackGroundViewSegment.setImage(image, forSegmentAt: index)
//                 }
//             }
//         }
//    }

//    private func setupSegmentedControl() {
//        let originalImages = [
//            AnimationSet.case0.rawValue,
//            AnimationSet.case1.rawValue,
//            AnimationSet.case2.rawValue,
//            AnimationSet.case3.rawValue,
//            AnimationSet.case4.rawValue
//        ]
//
//        for (index, imageName) in originalImages.enumerated() {
//            if let image = UIImage(named: "\(imageName)1")?.withRenderingMode(.alwaysOriginal) {
//                selectBackGroundViewSegment.setImage(image, forSegmentAt: index)
//            }
//        }
//    }
    
    // MARK: - Actions
    @IBAction func selectBackGroundViewSegmentChanged(_ sender: Any) {
        if let segmentControl = sender as? UISegmentedControl {
            AnimationUtility.applyAnimation(on: backGroundView, forBackgroundViewIndex: segmentControl.selectedSegmentIndex)
        }
//        applyAnimationBasedOnSegmentIndex((sender as AnyObject).selectedSegmentIndex)
//        selectBackGroundViewSegment.addTarget(self, action: #selector(selectBackGroundViewSegmentChanged(_:)), for: .valueChanged)
    }
    
    @IBAction func postAction(_ sender: Any) {
        let realm = try! Realm()
        if isNewPerson {
            let newPerson = Person()
            newPerson.id = (realm.objects(Person.self).max(ofProperty: "id") as Int? ?? 0) + 1
            newPerson.personName = personNameTextField.text
            newPerson.smallImage = smallImage?.jpegData(compressionQuality: 0.01)
            newPerson.bigImage = bigImage?.jpegData(compressionQuality: 0.01)
            newPerson.backgroundViewIndex = selectBackGroundViewSegment.selectedSegmentIndex
            do {
                try realm.write {
                    realm.add(newPerson)
                }
            } catch {
                print("Error saving new person to Realm: \(error)")
            }
        } else {
            guard let id = editingPersonID, let personToUpdate = realm.object(ofType: Person.self, forPrimaryKey: id) else {
                return
            }
            do {
                try realm.write {
                    personToUpdate.personName = personNameTextField.text
                    personToUpdate.smallImage = smallImage?.jpegData(compressionQuality: 0.01)
                    personToUpdate.bigImage = bigImage?.jpegData(compressionQuality: 0.01)
                    personToUpdate.backgroundViewIndex = selectBackGroundViewSegment.selectedSegmentIndex
                }
            } catch {
                print("Error updating the person in Realm: \(error)")
            }
        }
        if let navController = navigationController {
            navController.popViewController(animated: true)
        }
    }

    @IBAction func editPersonImageTapped(_ sender: Any) {
        selectImageUtility.showAlert(self)
    }
    
    // MARK: - Helper Functions
    private func applyAnimationBasedOnSegmentIndex(_ index: Int) {
        if let animationSet = AnimationSet.from(backgroundViewIndex: index) {
            BackGroundAnimationUtility.applyAnimation(on: backGroundView, withPrefix: animationSet.rawValue)
        }
    }


    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            smallImage = selectedImage
            personsSmallPhotoImageView.image = smallImage
        }

        if let originalImage = info[.originalImage] as? UIImage {
            bigImage = originalImage
            personsBigPhotoImageView.image = bigImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BackGroundAnimationUtility
struct BackGroundAnimationUtility {
    static func applyAnimation(on view: UIView, withPrefix prefix: String) {
        guard let imageView = view as? UIImageView,
              let animationImages = fetchAnimationImages(withPrefix: prefix),
              !animationImages.isEmpty else {
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
struct AnimationUtility {
    static func animationSetFrom(backgroundViewIndex: Int) -> AnimationSet {
        switch backgroundViewIndex {
        case 0:
            return .case0
        case 1:
            return .case1
        case 2:
            return .case2
        case 3:
            return .case3
        case 4:
            return .case4
        default:
            return .case4
        }
    }
    
    static func applyAnimation(on view: UIImageView, forBackgroundViewIndex index: Int) {
        let animationSet = self.animationSetFrom(backgroundViewIndex: index)
        BackGroundAnimationUtility.applyAnimation(on: view, withPrefix: animationSet.rawValue)
    }
}
// MARK: - UIImage Extension
extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

