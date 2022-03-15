//
//  ViewController.swift
//  MemeMe
//
//  Created by Ashley Thornton on 2/19/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var UItoolbar: UIToolbar!
    
    var meme: Meme?
    
    private var isEditingBottomTextField = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.save()
        guard let activityVC = segue.destination as? ActivityViewController else{return}
        activityVC.meme = self.meme
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
        if isEditingBottomTextField {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if isEditingBottomTextField {
            view.frame.origin.y += getKeyboardHeight(notification)
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
            selectImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    
    }
    
    func save() {
        let memedImage = generateMemedImage()
        self.meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectImageView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        self.UItoolbar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.UItoolbar.isHidden = false
//        self.UItoolbar.isHidden.toggle()
        self.navigationController?.navigationBar.isHidden = false

        return memedImage
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isEditingBottomTextField = textField == self.bottomTextField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.bottomTextField {
            self.isEditingBottomTextField = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func selectImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func selectImageFromCamera(_ sender: Any) {
        checkCameraAuthorization { isAuthorized in
            if isAuthorized {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present (imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func checkCameraAuthorization(thenPerform completion: @escaping (Bool) -> Void) {
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
    
    // MARK: - Internal
    
    private func configureTextFields() {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: -3.0
        ]
        
        topTextField.text = "TOP"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.delegate = self
        topTextField.clearsOnBeginEditing = true
        topTextField.textAlignment = .center
        
        bottomTextField.text = "BOTTOM"
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.delegate = self
        bottomTextField.clearsOnBeginEditing = true
        bottomTextField.textAlignment = .center
    }
    
}

