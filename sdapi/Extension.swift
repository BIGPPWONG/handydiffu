// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import SwiftUI
import Accelerate


extension Data {
    /// Creates a new buffer by copying the buffer pointer of the given array.
    ///
    /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
    ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
    ///     data from the resulting buffer has undefined behavior.
    /// - Parameter array: An array with elements of type `T`.
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }
    
    /// Convert a Data instance to Array representation.
    func toArray<T>(type: T.Type) -> [T] where T: AdditiveArithmetic {
        var array = [T](repeating: T.zero, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

//extension UIImage {
//    convenience init?(data: Data, size: CGSize, castFactor:Float = 255.0) {
//        let width = Int(size.width)
//        let height = Int(size.height)
//        
//        let floats = data.toArray(type: Float32.self)
//        
//        let bufferCapacity = width * height * 4
//        let unsafePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferCapacity)
//        let unsafeBuffer = UnsafeMutableBufferPointer<UInt8>(
//            start: unsafePointer,
//            count: bufferCapacity)
//        defer {
//            unsafePointer.deallocate()
//        }
//        
//        for x in 0..<width {
//            for y in 0..<height {
//                let floatIndex = (y * width + x) * 3
//                let index = (y * width + x) * 4
//                //                print(floats[floatIndex+2])
//                
//                let red = UInt8(floats[floatIndex].clamped(to: 0...1) * castFactor)
//                let green = UInt8(floats[floatIndex + 1].clamped(to: 0...1) * castFactor)
//                let blue = UInt8(floats[floatIndex + 2].clamped(to: 0...1) * castFactor)
//                
//                unsafeBuffer[index] = red
//                unsafeBuffer[index + 1] = green
//                unsafeBuffer[index + 2] = blue
//                unsafeBuffer[index + 3] = 0
//            }
//        }
//        
//        let outData = Data(buffer: unsafeBuffer)
//        //        print("222222")
//        //        print(outData)
//        
//        // Construct image from output tensor data
//        let alphaInfo = CGImageAlphaInfo.noneSkipLast
//        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
//            .union(.byteOrder32Big)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        guard
//            let imageDataProvider = CGDataProvider(data: outData as CFData),
//            let cgImage = CGImage(
//                width: width,
//                height: height,
//                bitsPerComponent: 8,
//                bitsPerPixel: 32,
//                bytesPerRow: MemoryLayout<UInt8>.size * 4 * Int(size.width),
//                space: colorSpace,
//                bitmapInfo: bitmapInfo,
//                provider: imageDataProvider,
//                decode: nil,
//                shouldInterpolate: false,
//                intent: .defaultIntent
//            )
//        else {
//            return nil
//        }
//        self.init(cgImage: cgImage)
//    }
//}


extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}


extension UIImage {
    
    /// Helper function to center-crop image.
    /// - Returns: Center-cropped copy of this image
    func cropCenter() -> UIImage? {
        { [ unowned self ] in
            // Don't do anything if the image is already square.
            guard size.height != size.width else {
                return self
            }
            let isPortrait = size.height > size.width
            let smallestDimension = min(size.width, size.height)
            let croppedSize = CGSize(width: smallestDimension, height: smallestDimension)
            let croppedRect = CGRect(origin: .zero, size: croppedSize)
            
            UIGraphicsBeginImageContextWithOptions(croppedSize, false, scale)
            let croppingOrigin = CGPoint(
                x: isPortrait ? 0 : floor((size.width - size.height) / 2),
                y: isPortrait ? floor((size.height - size.width) / 2) : 0
            )
            guard let cgImage = cgImage?.cropping(to: CGRect(origin: croppingOrigin, size: croppedSize))
            else { return nil }
            UIImage(cgImage: cgImage).draw(in: croppedRect)
            let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            var tempImageData = croppedImage!.jpegData(compressionQuality: 1.0)
            return UIImage(data: tempImageData!)
            //        return croppedImage
        }()
    }
    
    func crop(posX:CGFloat,posY:CGFloat,width:CGFloat,height:CGFloat) -> UIImage {
        { [ unowned self ] in
            let cgimage = self.cgImage!
            //        let contextImage: UIImage = UIImage(cgImage: cgimage)
            let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
            
            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!
            
            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
            
            //        UIImage(cgImage: imageRef).draw(in: rect)
            //        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
            //        UIGraphicsEndImageContext()
            
            return image
        }()
    }
    
    func pad(padSize: CGFloat) -> UIImage? {
        { [ unowned self ] in
            //        let size = CGSize(width: self.size.width+2*padSize, height: self.size.height+2*padSize)
            //        let format = UIGraphicsImageRendererFormat.default()
            //        format.scale = scale
            //        let renderer = UIGraphicsImageRenderer(size: size, format: format)
            //        let imageData = renderer.jpegData(withCompressionQuality: 1.0) { _ in
            //            self.draw(in: CGRect(x:0, y:0, width: self.size.width+2*padSize, height: self.size.height+2*padSize))
            //            self.draw(in: CGRect(x:padSize, y:padSize, width: self.size.width, height: self.size.height))
            //        }
            ////        return image
            //        return UIImage(data: imageData)
            
            let size = CGSize(width: self.size.width+2*padSize, height: self.size.height+2*padSize)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            self.draw(in: CGRect(x:0, y:0, width: self.size.width+2*padSize, height: self.size.height+2*padSize))
            self.draw(in: CGRect(x:padSize, y:padSize, width: self.size.width, height: self.size.height))
            let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            var tempImageData = paddedImage!.jpegData(compressionQuality: 1.0)
            return UIImage(data: tempImageData!)
            //        return paddedImage
        }()
    }
    
    static func concat( imgArr: UnsafeMutableBufferPointer<UIImage?>,direction: Int) -> UIImage? {
        return autoreleasepool { () -> UIImage? in
            //        direction 0 hortional, 1 vertical
            var width:CGFloat = 0
            var height:CGFloat = 0
            if direction == 0 {
                height = imgArr[0]!.size.height
                for img in imgArr {
                    width+=img!.size.width
                }
            } else {
                width = imgArr[0]!.size.width
                for img in imgArr {
                    height += img!.size.height
                }
            }
            let size = CGSize(width: width, height: height)
            
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1.0
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            let image = renderer.image { _ in
                var currentWidth:CGFloat = 0
                var currentHeight:CGFloat = 0
                if direction == 0 {
                    for indice in 0..<imgArr.count {
                        autoreleasepool {
                            imgArr[indice]!.draw(in: CGRect(x:currentWidth, y:currentHeight, width: imgArr[indice]!.size.width, height: imgArr[indice]!.size.height))
                            currentWidth += imgArr[indice]!.size.width
                    
                            imgArr[indice] = nil
                            
                        }
                    }
                } else {
                    for indice in 0..<imgArr.count {
                        autoreleasepool {
                            imgArr[indice]!.draw(in: CGRect(x:currentWidth, y:currentHeight, width: imgArr[indice]!.size.width, height: imgArr[indice]!.size.height))
                            currentHeight += imgArr[indice]!.size.height
                            imgArr[indice] = nil
                        }
                    }
                }
                //            topImage?.draw(in: CGRect(x:0, y:0, width:size.width, height: (topImage?.size.height)!))
                //            bottomImage?.draw(in: CGRect(x:0, y:(topImage?.size.height)!, width: size.width,  height: (bottomImage?.size.height)!))
            }
            return image
//            return UIImage(data: imageData)
            
//            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//            var currentWidth:CGFloat = 0
//            var currentHeight:CGFloat = 0
//            if direction == 0 {
//                for img in imgArr {
//                    img.draw(in: CGRect(x:currentWidth, y:currentHeight, width: img.size.width, height: img.size.height))
//                    currentWidth += img.size.width
//                }
//            } else {
//                for img in imgArr {
//                    img.draw(in: CGRect(x:currentWidth, y:currentHeight, width: img.size.width, height: img.size.height))
//                    currentHeight += img.size.height
//                }
//            }
//            var concatImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            var tempImageData = concatImage!.jpegData(compressionQuality: 1.0)
//            concatImage = nil
//            return UIImage(data: tempImageData!)
        }
    }
    
//    padSize 是replacement的
    func replaceRect(rect: CGRect,replacement: UIImage,padSize:CGFloat = 0) -> UIImage? {
        
        return autoreleasepool { [ unowned self ] () -> UIImage? in
        let size = CGSize(width: self.size.width, height: self.size.height)
        let format = UIGraphicsImageRendererFormat.default()
            format.scale = self.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { _ in
            self.draw(in: CGRect(x:0, y:0, width: self.size.width, height: self.size.height))
            var replaceX: CGFloat = 0
            var replaceY: CGFloat = 0
            var replaceWidth: CGFloat = 0
            var replaceHeight: CGFloat = 0
            replaceX = {
                if rect.minX < 0 {
                    replaceWidth = rect.width - abs(rect.minX)
                    return 0
                } else {
                    replaceWidth = rect.width
                    return rect.minX
                }
            }()
            replaceY = {
                if rect.minY < 0 {
                    replaceHeight = rect.height - abs(rect.minY)
                    return 0
                } else {
                    replaceHeight = rect.height
                    return rect.minY
                }
            }()
//            let replaceX = max(0,rect.minX)
//            let replaceY = max(0,rect.minY)
//            var replaceWidth = min(rect.width,self.size.width - replaceX)
//            var replaceHeight = min(rect.height,self.size.height - replaceY)
            if replacement.size.width > replacement.size.height {
                replaceHeight = replaceWidth * replacement.size.height / replacement.size.width
            } else {
                replaceWidth = replaceHeight * replacement.size.width / replacement.size.height
            }
            let replaceOffsetX = ceil(padSize / replacement.size.width * replaceWidth)
            let replaceOffsetY = ceil(padSize / replacement.size.height * replaceHeight)

            replaceWidth -= 2*replaceOffsetX
            replaceHeight -= 2*replaceOffsetY
            replaceWidth = replaceWidth
            replaceHeight = replaceHeight
            

            let replacementCrop = replacement.crop(posX: padSize, posY: padSize, width: replacement.size.width-2*padSize, height: replacement.size.height-2*padSize)

            let replaceRect = CGRect(x: ceil(replaceX+replaceOffsetX),
                                     y: ceil(replaceY+replaceOffsetY),
                                     width: floor(replaceWidth),
                                     height: floor(replaceHeight)
            )
            print(padSize)
            print(replaceOffsetX)
            print(replaceOffsetY)
            print(rect)
            print(replaceRect)
            print(replacement.size)
            
//            print("replaceRect")
//            print(replaceRect)
            //
            replacementCrop.draw(in: replaceRect)
        }
//        return UIImage(data: imageData)
            return image
//            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//            self.draw(in: CGRect(x:0, y:0, width: self.size.width, height: self.size.height))
//            let replaceX = max(0,rect.minX)
//            let replaceY = max(0,rect.minY)
//            var replaceWidth = min(rect.width,self.size.width - replaceX)
//            var replaceHeight = min(rect.height,self.size.height - replaceY)
//            if replacement.size.width > replacement.size.height {
//                replaceHeight = replaceWidth * replacement.size.height / replacement.size.width
//            } else {
//                replaceWidth = replaceHeight * replacement.size.width / replacement.size.height
//            }
//            let replaceOffsetX = padSize / replacement.size.width * replaceWidth
//            let replaceOffsetY = padSize / replacement.size.height * replaceHeight
//
//            replaceWidth -= 2*replaceOffsetX
//            replaceHeight -= 2*replaceOffsetY
//
//            let replacementCrop = replacement.crop(posX: padSize, posY: padSize, width: replacement.size.width-2*padSize, height: replacement.size.height-2*padSize)
//
//            let replaceRect = CGRect(x: replaceX+replaceOffsetX,
//                                     y: replaceY+replaceOffsetY,
//                                     width: replaceWidth,
//                                     height: replaceHeight)
//            //            print("replaceRect")
//            //            print(replaceRect)
//            //
//            replacementCrop.draw(in: replaceRect)
//            var concatImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            var tempImageData = concatImage!.jpegData(compressionQuality: 1.0)
//            concatImage =  nil
//            return UIImage(data: tempImageData!)
//            return concatImage
        }
    }
    
    func cropToRatio(width: Double, height: Double) -> UIImage? {
        { [ unowned self ] in
            
            let cgimage = self.cgImage!
            //        print("cgisize")
            //        print(cgimage.height)
            //        print(cgimage.width)
            //        let contextImage: UIImage = UIImage(cgImage: cgimage)
            //        let contextSize: CGSize = contextImage.size
            var posX: CGFloat = 0.0
            var posY: CGFloat = 0.0
            let cgwidth: CGFloat = CGFloat(cgimage.width)
            let cgheight: CGFloat = CGFloat(cgimage.height)
            var outWidth: CGFloat = 0
            var outHeight: CGFloat = 0
            
            // See what size is longer and create the center off of that
            if width > height {
                outWidth = cgwidth
                outHeight = cgwidth / width * height
                posY = ((cgheight - outHeight) / 2)
                posX = 0
                //            cgwidth = contextSize.height
                //            cgheight = contextSize.height
            } else {
                outHeight = cgheight
                outWidth = cgheight/height * width
                //            print("outwidth")
                //            print("\(cgwidth) \(cgheight) \(outHeight) \(outWidth)")
                posY = 0
                posX = ((cgwidth - outWidth) / 2)
                //            print(contextSize.width)
                //            print(cgwidth)
                //            cgwidth = contextSize.width
                //            cgheight = contextSize.width
            }
            //        let size = CGSize(width: outWidth, height: outHeight)
            //        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            
            let rect: CGRect = CGRect(x: posX, y: posY, width: CGFloat(Int(outWidth)), height: CGFloat(Int(outHeight)))
            
            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!
            
            // Create a new image based on the imageRef and rotate back to the original orientation
            let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
            //        let croppedSize = CGSize(width: width, height: height)
            //        let croppedRect = CGRect(origin: .zero, size: croppedSize)
            //
            //        guard let cgImage = cgImage?.cropping(to: rect)
            //        else { return nil }
            //        UIImage(cgImage: cgImage).draw(in: croppedRect)
            //        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
            //        UIGraphicsEndImageContext()
            
            return croppedImage
        }()
    }
    
    func resizeToFitPixels(maxPixels: Double) -> UIImage?  {
        { [ unowned self ] in
            let cgimage = self.cgImage!
            
            let contextImage: UIImage = UIImage(cgImage: cgimage)
            let contextSize: CGSize = contextImage.size
            let contextWidth: CGFloat = contextSize.width
            let contextHeight: CGFloat = contextSize.height
            let contextPixels = contextWidth * contextHeight
            let scale = sqrt(maxPixels/contextPixels)
            let outWidth = contextWidth * scale
            let outHeight = contextHeight * scale
            let orientation = self.imageOrientation
            if (orientation == .right || orientation == .left) {
                return self.resized(to: CGSize(width: outHeight, height: outWidth))
            } else {
                return self.resized(to: CGSize(width: outWidth, height: outHeight))
            }
        }()
    }
    
    func canBeDividedBy(num: Int) -> UIImage {
        { [ unowned self ] in
            let ph = ((Int(self.size.height) - 1) / num + 1) * num
            let pw = ((Int(self.size.width) - 1) / num + 1) * num
            return self.resized(to: CGSize(width: pw, height: ph))
        }()
    }
    
    func rotateImage() -> UIImage {
        { [ unowned self ] in
            var rotatedImage = UIImage()
//            switch self.imageOrientation {
//                case .right:
//                    rotatedImage = UIImage(cgImage: self.cgImage!, scale: scale, orientation: .down)
//                case .down:
//                    rotatedImage = UIImage(cgImage: self.cgImage!, scale: scale, orientation: .left)
//                case .left:
//                    rotatedImage = UIImage(cgImage: self.cgImage!, scale: scale, orientation: .up)
//                default:
//                    rotatedImage = UIImage(cgImage: self.cgImage!, scale: scale, orientation: .right)
//                }
            
            switch self.imageOrientation {
            case .right:
                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .up)
            case .down:
                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .right)
            case .left:
                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .down)
            case .up:
                rotatedImage = self
            default:
                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .left)
            }
            return rotatedImage
        }()
    }
    
//    func rotateImageBack() -> UIImage {
//        { [ unowned self ] in
//            var rotatedImage = UIImage()
//            switch self.imageOrientation {
//            case .up:
//                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .right)
//            case .right:
//                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .down)
//            case .down:
//                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .left)
//            case .up:
//                rotatedImage = self
//            default:
//                rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .left)
//            }
//            return rotatedImage
//        }()
//    }
    
}

extension CGFloat {
    func isNegative() -> Bool {
        if self < 0 {
            return true
        } else {
            return false
        }
    }
}

func isTestFlight() -> Bool {
    if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        return true
    } else {
        return false
    }
}
