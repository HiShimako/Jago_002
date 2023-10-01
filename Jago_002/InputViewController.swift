// InputViewController.swift
// Jago_002
//
// Created by user on 2023/09/11.

import UIKit
import RealmSwift

enum AnimationSet: String {
    case case0 = "4_out00"
    case case1 = "6_out00"
    case case2 = "frame_apngframe2"
    case case3 = "frame_apngframe3"
    case case4 = "frame_apngframe0"
    
    static var allCases: [AnimationSet] {
        return [.case0, .case1, .case2, .case3, .case4]
    }
}
protocol SelectImageUtilityDelegate: AnyObject {
    func didPickImages(smallImage: UIImage?, bigImage: UIImage?)
}
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
        personsSmallPhotoImageView.layer.cornerRadius = personsSmallPhotoImageView.frame.width * 0.10
        personsSmallPhotoImageView.clipsToBounds = true
        
        personsBigPhotoImageView.layer.cornerRadius = personsBigPhotoImageView.frame.width * 0.10
        personsBigPhotoImageView.clipsToBounds = true
        
        loadEditingPersonData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupInitialStates()
    }

    // MARK: - Initialization Methods
    private func setupInitialStates() {
        // ImageViewのnilチェック
        personsSmallPhotoImageView?.image = smallImage
        personsBigPhotoImageView?.image = bigImage

        if let personID = editingPersonID {
            // 編集モードの場合
            let realm = try! Realm()
            if let personToEdit = realm.object(ofType: Person.self, forPrimaryKey: personID),
               let segmentControl = selectBackGroundViewSegment {
                // 対応するbackgroundViewIndexをRealmから取得し、セグメントコントロールにセットします。
                segmentControl.selectedSegmentIndex = personToEdit.backgroundViewIndex
            }
        } else if selectBackGroundViewSegment?.selectedSegmentIndex == UISegmentedControl.noSegment {
            // 新規追加モードの場合、セグメントコントロールの初期選択がなければ0をセットします。
            selectBackGroundViewSegment?.selectedSegmentIndex = 0
        }

        // selectBackGroundViewSegmentがnilでないことを確認してからapplyAnimationを呼び出す
        if let segmentIndex = selectBackGroundViewSegment?.selectedSegmentIndex {
            applyAnimation(on: backGroundView, forBackgroundViewIndex: segmentIndex)
        }
        
        setupSegmentedControl()
  
    }
    private func setupSegmentedControl() {
        for index in 0..<selectBackGroundViewSegment.numberOfSegments {
            let animationSet = animationSetFrom(backgroundViewIndex: index)
                if let image = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
                    selectBackGroundViewSegment.setImage(image, forSegmentAt: index)
                }
            
        }
    }

    private func loadEditingPersonData() {
        guard let id = editingPersonID else { return }
        
        let realm = try! Realm()
        if let personToEdit = realm.object(ofType: Person.self, forPrimaryKey: id) {
            // 小さな画像と大きな画像を取得
            if let smallImageData = personToEdit.smallImage {
                self.smallImage = UIImage(data: smallImageData)
            }
            
            if let bigImageData = personToEdit.bigImage {
                self.bigImage = UIImage(data: bigImageData)
            }
            
            // backgroundViewIndexを取得
            self.backgroundViewIndex = personToEdit.backgroundViewIndex
        }
    }

    
    // MARK: - Actions
    @IBAction func selectBackGroundViewSegmentChanged(_ sender: Any) {
        if let segmentControl = sender as? UISegmentedControl {
            applyAnimation(on: backGroundView, forBackgroundViewIndex: segmentControl.selectedSegmentIndex)
        }

    }
    
    @IBAction func postAction(_ sender: Any) {
        do {
            let realm = try Realm()
            let smallImageData = smallImage?.jpegData(compressionQuality: 0.01)
            let bigImageData = bigImage?.jpegData(compressionQuality: 0.01)
            let backgroundIndex = selectBackGroundViewSegment.selectedSegmentIndex

            if isNewPerson {
                let newPerson = Person()
                // 下記の行を修正
                newPerson.id = (realm.objects(Person.self).max(ofProperty: "id") ?? -1) + 1
                newPerson.personName = personNameTextField.text
                newPerson.smallImage = smallImageData
                newPerson.bigImage = bigImageData
                newPerson.backgroundViewIndex = backgroundIndex

                try realm.write {
                    realm.add(newPerson)
                }
            } else if let id = editingPersonID, let personToUpdate = realm.object(ofType: Person.self, forPrimaryKey: id) {
                try realm.write {
                    personToUpdate.personName = personNameTextField.text
                    personToUpdate.smallImage = smallImageData
                    personToUpdate.bigImage = bigImageData
                    personToUpdate.backgroundViewIndex = backgroundIndex
                }
            }

            if let navController = navigationController {
                navController.popViewController(animated: true)
            }
        } catch {
            print("Error with Realm operation: \(error)")
        }
    }

    let selectImageUtility = SelectImageUtility()

    @IBAction func editPersonImageTapped(_ sender: Any) {
        selectImageUtility.didPickImages = { [weak self] smallImg, bigImg in
            self?.smallImage = smallImg
            self?.bigImage = bigImg
            self?.personsSmallPhotoImageView.image = smallImg
            self?.personsBigPhotoImageView.image = bigImg
        }
        selectImageUtility.showAlert(from: self)
    }
    
}
extension InputViewController: SelectImageUtilityDelegate {
    func didPickImages(smallImage: UIImage?, bigImage: UIImage?) {
        print("🔍 Received Small Image: \(String(describing: smallImage))")
           print("🔍 Received Big Image: \(String(describing: bigImage))")
        self.smallImage = smallImage
        self.bigImage = bigImage
        personsSmallPhotoImageView.image = smallImage
        personsBigPhotoImageView.image = bigImage
    }
}

// MARK: - BackGroundAnimationUtility
func animationSetFrom(backgroundViewIndex: Int) -> AnimationSet {
    if backgroundViewIndex >= 0 && backgroundViewIndex < AnimationSet.allCases.count {
        return AnimationSet.allCases[backgroundViewIndex]
    }
    return AnimationSet.allCases[0]
}

func applyAnimation(on view: UIImageView, forBackgroundViewIndex index: Int) {
    let animationSet = animationSetFrom(backgroundViewIndex: index)
    applyBackgroundAnimation(on: view, withPrefix: animationSet.rawValue)
}

func applyBackgroundAnimation(on view: UIView, withPrefix prefix: String) {
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

func fetchAnimationImages(withPrefix prefix: String) -> [UIImage]? {
    var backGroundImageArray: [UIImage] = []
    var index = 1
    while let image = UIImage(named: "\(prefix)\(index)") {
        backGroundImageArray.append(image)
        index += 1
    }
    return backGroundImageArray.isEmpty ? nil : backGroundImageArray
}

// MARK: - UIImage Extension
extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

