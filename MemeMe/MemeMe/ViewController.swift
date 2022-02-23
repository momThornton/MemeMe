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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: 3.0
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
        
//        [topTextField, bottomTextField].forEach { tf in
//            guard let tf = tf else { return }
//            tf.textAlignment = .center
//            tf.defaultTextAttributes = memeTextAttributes
//            tf.delegate = self
//        }
//
//        for tf in [topTextField, bottomTextField] {
//            guard let tf = tf else { break }
//            tf.textAlignment = .center
//            tf.defaultTextAttributes = memeTextAttributes
//            tf.delegate = self
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
//        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
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
    
    // MARK: - UITextFieldDelegate
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.text = nil
//    }
    
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
    
}

