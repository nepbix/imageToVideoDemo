//
//  VC+AppendVideos.swift
//  imageToVideoDemo
//
//  Created by Praks on 2/12/20.
//  Copyright © 2020 Xtrastaff. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary

extension ViewController {
    func mergeVideos(videoLocations: [URL], completion: @escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {
            
            let arrayVideos = videoLocations.compactMap { (url) -> AVAsset? in
                AVAsset(url: url)
            }

            let mainComposition = AVMutableComposition()
            let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

            let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

            var insertTime = CMTime.zero

            for videoAsset in arrayVideos {
                try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
                try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

                insertTime = CMTimeAdd(insertTime, videoAsset.duration)
            }

            let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "merge.mp4")

    //        let fileManager = FileManager()
    //      fileManager.removeItemIfExisted(outputFileURL)
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch let error as NSError {
                print("Error: \(error.domain)")
            }

            let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)

            exporter?.outputURL = outputFileURL
            exporter?.outputFileType = AVFileType.mp4
            exporter?.shouldOptimizeForNetworkUse = true

            exporter?.exportAsynchronously {
                DispatchQueue.main.async {
                    completion(exporter!)
                }
            }
        }
}
