//
//  ViewController.swift
//  MemeMe
//
//  Created by Ashley Thornton on 2/19/22.
//

import UIKit
import AVFoundation

class MemeEditorController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    private var isPortraitOrientation: Bool { UIDevice.current.orientation.isPortrait }
    
    private var text: (top: String, bottom: String) { (topTextField.text ?? .empty, bottomTextField.text ?? .empty) }
    
    private let defaultText = (top: "TOP", bottom: "BOTTOM")
    private var explicitlyWroteDefault = (top: false, bottom: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure(topTextField, withLabel: defaultText.top)
        self.configure(bottomTextField, withLabel: defaultText.bottom)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didClickActionButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didClickCancelButton))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = false
            cameraButton.tintColor = .systemGray
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func selectImageFromAlbum(_ sender: Any) {
        self.chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    @IBAction func selectImageFromCamera(_ sender: Any) {
        guard cameraButton.isEnabled else {
            print("selectImageFromCamera: camera is not available")
            return
        }
        checkCameraAuthorization { isAuthorized in
            if isAuthorized {
                self.chooseImageFromCameraOrPhoto(source: .camera)
            }
        }
    }
    @objc func didClickCancelButton() {
        self.dismiss(animated: true)
    }
    @objc func didClickActionButton() {
        let activityVC = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activity, didComplete, items, error in
            if didComplete {
                self.save()
                self.dismiss(animated: true)
            }
        }
        present(activityVC, animated: true)
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
 
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            let defaultText = (textField == topTextField) ? defaultText.top : defaultText.bottom
            textField.text = defaultText
            return
        }
        
        if textField == topTextField {
            explicitlyWroteDefault.top = textField.text == defaultText.top
        } else {
            explicitlyWroteDefault.bottom = textField.text == defaultText.bottom
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Internal
    
    private func checkCameraAuthorization(thenPerform completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Capture access already granted")
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { accessIsGranted in
                print("Capture access granted: \(accessIsGranted)")
                completion(accessIsGranted)
            }
        case .denied:
            print("Capture access denied")
        case .restricted:
            print("Capture access restricted")
        @unknown default:
            fatalError()
        }
    
    }
    
    private func configure(_ tf: UITextField, withLabel text: String) {
        tf.text = text
        tf.defaultTextAttributes = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: -1.0,
        ]
        tf.textAlignment = .center
        tf.clearsOnBeginEditing = true
        tf.delegate = self
    }
    
    private func hideNavigationBar(hide isHidden: Bool) {
        self.navigationController?.navigationBar.isHidden = isHidden
        self.navigationController?.toolbar.isHidden = isHidden
    }
    
    private func hideDefaultText(hide isHidden: Bool) {
        if isHidden {
            if !explicitlyWroteDefault.top && text.top == defaultText.top { configure(topTextField, withLabel: .empty) }
            if !explicitlyWroteDefault.bottom && text.bottom == defaultText.bottom { configure(bottomTextField, withLabel: .empty) }
        } else {
            if text.top.isEmpty { configure(topTextField, withLabel: defaultText.top) }
            if text.bottom.isEmpty { configure(bottomTextField, withLabel: defaultText.bottom) }
        }
        
    }
    
    private func save() {
        guard let image = imageView.image else { return }
        let memedImage = generateMemedImage()
        let text = (top: topTextField.text ?? .empty, bottom: bottomTextField.text ?? .empty)
        let meme = Meme(topText: text.top, bottomText: text.bottom, originalImage: image, memedImage: memedImage)
        MemeStore.shared.save(meme: meme)
    }
    
    private func generateMemedImage() -> UIImage {
        self.hideNavigationBar(hide: true)
        self.hideDefaultText(hide: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.hideNavigationBar(hide: false)
        self.hideDefaultText(hide: false)
        return memedImage
    }
    
    private func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        // This requires self to adopt UINavigationControllerDelegate
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
}

