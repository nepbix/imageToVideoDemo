//
//  ImageExtension.swift
//  imageToVideoDemo
//
//  Created by Praks on 2/13/20.
//  Copyright © 2020 Xtrastaff. All rights reserved.
//

import UIKit

extension UIImage {
    func applyBlur(with amount: CGFloat) -> UIImage {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        blurfilter?.setValue(amount, forKey: kCIInputRadiusKey)
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        return UIImage(ciImage: resultImage)
    }
    
    
    func drawImage(inImage backgroundImage: UIImage) -> UIImage {
        let aspectRatioForeground = self.size.width / self.size.height

        guard (aspectRatioForeground != 16 / 9) else {
            return self
        }

        let maintainedWidthForeground = aspectRatioForeground * backgroundImage.size.height

        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect.init(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))

        self.draw(in: CGRect.init(x: backgroundImage.size.width / 2 - maintainedWidthForeground / 2,
            y: 0,
            width: maintainedWidthForeground,
            height: backgroundImage.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    func drawImageSameBackground(with size: CGSize = CGSize(width: 1920, height: 1080)) -> UIImage {
        let aspectRatioForeground = self.size.width / self.size.height
        
        let convertToCGImage = self.cgImage!
        let blurredImage = HannBlur(cgImage: convertToCGImage).applyBlur()!
        let backgroundImage = blurredImage
        
        guard (aspectRatioForeground != 16 / 9) else {
            return self
        }

        let maintainedWidthForeground = aspectRatioForeground * size.height

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        backgroundImage.draw(in: CGRect.init(x: 0,
                                             y: 0,
                                             width: size.width,
                                             height: size.height))

        self.draw(in: CGRect.init(x: size.width / 2 - maintainedWidthForeground / 2,
            y: 0,
            width: maintainedWidthForeground,
            height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
