//
//  HannBlur.swift
//  imageToVideoDemo
//
//  Created by Praks on 2/13/20.
//  Copyright © 2020 Xtrastaff. All rights reserved.
//

import UIKit
import Accelerate
let kernelLength = 51

class HannBlur {
    init(cgImage: CGImage) {
        self.cgImage = cgImage
    }

    let machToSeconds: Double = {
        var timebase: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        return Double(timebase.numer) / Double(timebase.denom) * 1e-9
    }()

    var destinationBuffer = vImage_Buffer()

    var cgImage: CGImage!

    lazy var format: vImage_CGImageFormat = {
        guard
            let format = vImage_CGImageFormat(cgImage: cgImage) else {
                fatalError("Unable to get color space")
        }
        return format
    }()

    lazy var sourceBuffer: vImage_Buffer = {
        guard
        var sourceImageBuffer = try? vImage_Buffer(cgImage: cgImage),

        var scaledBuffer = try? vImage_Buffer(width: Int(sourceImageBuffer.width / 4),
            height: Int(sourceImageBuffer.height / 4),
            bitsPerPixel: format.bitsPerPixel) else {
            fatalError("Can't create source buffer.")
        }

        vImageScale_ARGB8888(&sourceImageBuffer,
                &scaledBuffer,
            nil,
            vImage_Flags(kvImageNoFlags))

        return scaledBuffer
    }()

    let hannWindow: [Float] = {
        return vDSP.window(ofType: Float.self,
            usingSequence: .hanningDenormalized,
            count: kernelLength,
            isHalfWindow: false)
    }()

    lazy var kernel1D: [Int16] = {
        let stride = vDSP_Stride(1)
        var multiplier = pow(Float(Int16.max), 0.25)

        let hannWindow1D = vDSP.multiply(multiplier, hannWindow)

        return vDSP.floatingPointToInteger(hannWindow1D,
            integerType: Int16.self,
            rounding: vDSP.RoundingMode.towardNearestInteger)
    }()

    func applyBlur() -> UIImage? {
        do {
            destinationBuffer = try vImage_Buffer(width: Int(sourceBuffer.width),
                height: Int(sourceBuffer.height),
                bitsPerPixel: format.bitsPerPixel)
        } catch {
            return nil
        }
        hann1D()
        if let result = try? destinationBuffer.createCGImage(format: format) {
            return UIImage(cgImage: result)
        }

        defer {
            destinationBuffer.free()
        }
        return nil
    }

    func hann1D() {
        let startTime = mach_absolute_time()

        let divisor = kernel1D.map { Int32($0) }.reduce(0, +)

        // Vertical pass.
        vImageConvolve_ARGB8888(&sourceBuffer,
                &destinationBuffer,
            nil,
            0, 0,
                &kernel1D,
            UInt32(kernelLength), // Height
            1, // Width
            divisor,
            nil,
            vImage_Flags(kvImageEdgeExtend))

        // Horizontal pass.
        vImageConvolve_ARGB8888(&destinationBuffer,
                &destinationBuffer,
            nil,
            0, 0,
                &kernel1D,
            1, // Height
            UInt32(kernelLength), // Width
            divisor,
            nil,
            vImage_Flags(kvImageEdgeExtend))

        let endTime = mach_absolute_time()
        print("hann1D", (machToSeconds * Double(endTime - startTime)))
    }
}
