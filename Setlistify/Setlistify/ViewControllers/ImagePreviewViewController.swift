//
//  ImagePreviewViewController.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 08/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit
import Kingfisher

class ImagePreviewViewController: UIViewController {

    var imageurl: URL?
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = imageurl {
            albumImageView.kf.setImage(with: url)
        }
    }
}
