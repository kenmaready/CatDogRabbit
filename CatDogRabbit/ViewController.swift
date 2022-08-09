//
//  ViewController.swift
//  CatDogRabbit
//
//  Created by Ken Maready on 8/7/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    var imagePicker = UIImagePickerController()
    let predictor = ImagePredictor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
        mainImage.image = UIImage(named: "select image")
    }

    @IBAction func selectImageTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerSetup() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            print("Camera is not available on this device/simulator. Select image from photo library.")
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("selected image: \(image)")
            mainImage.contentMode = .scaleAspectFit
            mainImage.image = image
            analyze(image)
        } else {
            print("unable to convert image to UIImage...")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func analyze(_ image: UIImage) {
            
        do {
            try predictor.predict(for: image, completionHandler: { predictions in
                if let safePredictions = predictions {
                    for prediction in safePredictions {
                        print("Guess: \(prediction.classification), confidence: \(prediction.confidence)")
                    }
                }
            })
        } catch {
            print("Error occurred in retrieving predictions from model: \(error.localizedDescription)")
        }
        
    }
}

