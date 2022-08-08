//
//  ViewController.swift
//  CatDogRabbit
//
//  Created by Ken Maready on 8/7/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    @IBAction func selectImageTapped(_ sender: UIBarButtonItem) {
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}

