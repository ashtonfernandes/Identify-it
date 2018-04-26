//
//  ViewController.swift
//  Identify It
//
//  Created by Ashton Fernandes on 2018-04-26.
//  Copyright © 2018 Ashton Fernandes. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //original image from camera or album
        //optional binding and downcasting
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Loading results failed")
            }
            let firstResult = results.first
            self.navigationItem.title = firstResult?.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}
