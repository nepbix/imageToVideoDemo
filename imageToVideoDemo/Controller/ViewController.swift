//
//  ViewController.swift
//  imageToVideoDemo
//
//  Created by Xtrastaff on 11/2/20.
//  Copyright © 2020 Xtrastaff. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import Photos
import AVKit


class ViewController: UIViewController {

    let outputSize = CGSize(width: 1920, height: 1080)
    let imagesPerSecond: TimeInterval = 3 //each image will be stay for 3 secs
    var selectedPhotosArray = [UIImage]()
    var imageArrayToVideoURL = NSURL()
    let audioIsEnabled: Bool = false //if your video has no sound


    var asset: AVAsset!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var activityMonitor: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityMonitor.isHidden = true
    }

    @IBAction func mergeImageAction(_ sender: Any) {
        self.buildVideoFromImageArray()
    }


    @IBAction func mergeVideoAction(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }

    @IBAction func playButtonAction(_ sender: Any) {
        self.statusLabel.text = ""
        if let galleryAsset = self.asset {
            let localVideoAsset = AVAsset(url: imageArrayToVideoURL as URL)
            let localAudioAsset = AVAsset(url: Bundle.main.url(forResource: "sampleAudio", withExtension: "mp3")!)
            self.mergeVid(with: localVideoAsset, secondAsset: galleryAsset, audioAsset: localAudioAsset)
        }
    }

    func playVideo(with url: URL) {
        DispatchQueue.main.async {
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: url)
            self.present(vc, animated: true) { vc.player?.play() }
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        dismiss(animated: true, completion: nil)
        guard let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL
            else { return }
        let message = "Video Loaded"
        let avAsset = AVAsset(url: url)
        self.asset = avAsset
        self.statusLabel.text = "Video Asset loaded from Gallery."
        let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
}

extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        dismiss(animated: true) {
            let selectedSongs = mediaItemCollection.items
            guard let song = selectedSongs.first else { return }

            let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
//      self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
            let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
            let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
