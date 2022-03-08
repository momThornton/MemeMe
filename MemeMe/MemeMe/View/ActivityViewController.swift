//
//  ActivityViewController.swift
//  MemeMe
//
//  Created by Ashley Thornton on 3/7/22.
//

import Foundation
import UIKit

class ActivityViewController: UIViewController {
    var meme: Meme?
  
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let memedImage = self.meme?.memedImage {
            imageView.image = memedImage
        }
    }
}

