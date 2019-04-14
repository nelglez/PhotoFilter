//
//  ViewController.swift
//  PhotoFilter
//
//  Created by Nelson Gonzalez on 3/18/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var choosePhoto: UIBarButtonItem!

    
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet weak var contrastSlider: UISlider!
    
    @IBOutlet weak var saturationSlider: UISlider!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //Takes care of rendering the filtered image
    let context = CIContext(options: nil)
    //a template for how to render the image. it doesnt actually do any editing/filtering
    let filter = CIFilter(name: "CIColorControls")!
    
    var originalImage: UIImage? {
        didSet {
           // updateImage()
            //Get a scaled down version of the original image
            guard let originalImage = originalImage else {return}
            
            //300 x 400
            let originalSize = imageView.bounds.size
            
            let deviceScale = UIScreen.main.scale //1x, 2x, or 3x
            
            //900 x 1200 (if a 3x device)
            let scaledSize = CGSize(width: originalSize.width * deviceScale, height: originalSize.height * deviceScale)
            
            //creates a scaled down copy of our image
             scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
           updateImage()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    private func presentImagePicker() {
        
       //Make sure that the source is available
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("Photo library is not avaiable in this device")
            //Present a good alert to the user here
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        //UIImage -> CGImage -> CIImage
        
        guard let cgImage = image.cgImage else {return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        //Set the filters params to the sliders values
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(saturationSlider.value, forKey: "inputSaturation")
        filter.setValue(brightnessSlider.value, forKey: "inputBrightness")
        filter.setValue(contrastSlider.value, forKey: "inputContrast")
        
        //CIImage -> CGImage -> UIImage
        
        //the metadata about how the image should be rendered with the filter
        guard let outputCIImage = filter.outputImage else {return image}
        
        //take the ciimage and run it through the CIcontext to create a tangible CGImage
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {return image}
        
        return UIImage(cgImage: outputCGImage)
        
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        }
    }

    @IBAction func savePhotoPressed(_ sender: UIButton) {
        
        guard let originalImage = self.originalImage else {return}
        
        let filteredImage = self.image(byFiltering: originalImage)
        
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else {return}
            
            //Filter the original image to get a full quality image
            
           
            
            PHPhotoLibrary.shared().performChanges({
                //any changes additions, edits, removals need to be done here
                
                PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
                
                
                
            }, completionHandler: { (success, error) in
                if let error = error {
                    print("Error saving photo to library: \(error)")
                    return
                }
                //present a successful save alert controller here
            })
        }
        
    }
    
    @IBAction func choosePhotoPressed(_ sender: UIBarButtonItem) {
        presentImagePicker()
    }
    
    @IBAction func changeBrightness(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func changeContrast(_ sender: UISlider) {
        updateImage()
    }
    
    
    @IBAction func changeSaturation(_ sender: UISlider) {
        updateImage()
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Gets called when an image is selected from the photo library or a photo is taken with the camera source type. Gives us access to the image.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Gets called when the user taps the cancel button on the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
