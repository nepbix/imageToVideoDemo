//
//  ViewController.swift
//  imageToVideoDemo
//
//  Created by Xtrastaff on 11/2/20.
//  Copyright © 2020 Xtrastaff. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let outputSize = CGSize(width: 1920, height: 1280)
    let imagesPerSecond: TimeInterval = 3 //each image will be stay for 3 secs
    var selectedPhotosArray = [UIImage]()
    var imageArrayToVideoURL = NSURL()
    let audioIsEnabled: Bool = false //if your video has no sound
    var asset: AVAsset!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.buildVideoFromImageArray()
    }

}

