//
//  ImageViewController.swift
//  Networking
//
//  Created by Valera Vasilevich on 30.07.21.
//

import UIKit

class ImageViewController: UIViewController {
    
    private let url = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        fetchImage()
    }
    
    func fetchImage() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        NetworkManager.downloadImage(url: url) { image in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }
        
    }
        
}
