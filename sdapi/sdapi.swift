//
//  sdapi.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import Foundation
import SwiftUI

func getApiUrl() -> String {
    @AppStorage("apiurl") var apiUrl: String = ""
//    print("apiurl: \(apiUrl)")
    return apiUrl
}

extension URL {
    func isReachable(completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}

func UIImage2base64(_ input: UIImage) -> String? {
    //Get data of existing UIImage
    let imageData = input.jpegData(compressionQuality: 0.3)
    // Convert image Data to base64 encodded string
    let imageBase64String = imageData?.base64EncodedString()
//    print(imageBase64String ?? "Could not encode image to Base64")
    return imageBase64String
}

func UIImage2dataurl(_ input: UIImage) -> String? {
    //Get data of existing UIImage
    let imageBase64String = UIImage2base64(input)
    let base64ImgPrefix = "data:image/jpeg;base64,"
    if let imageBase64String = imageBase64String {
        return base64ImgPrefix + imageBase64String
    } else {
        return nil
    }
}

func base642UIImage(base64String: String?) -> UIImage? {
    if let string = base64String {
        let decodedData = NSData(base64Encoded: string, options: [])
        if let data = decodedData {
            let decodedimage = UIImage(data: data as Data)
            return decodedimage
        } else {
            print("error with decodedData")
            return nil
        }
    } else {
        print("error with base64String")
        return nil
    }
}

typealias ErrorHandler = (_ error: String) -> Void
typealias ImageGenerationHandler = (_ resultImg: [UIImage]) -> Void

func txt2img(prompt:String , negative_prompt:String, handler: @escaping ImageGenerationHandler, errorHandler: @escaping ErrorHandler) {
    let config = sdConfig()
    let payload = txt2imgPayload(enable_hr: config.highres, prompt: config.promptPrefix + prompt, seed: config.seed, batch_size: Int(config.batchSize), n_iter: Int(config.batchCount),
                                 steps: Int(config.steps),
                                 cfg_scale: config.cfgScale, width: Int(config.width),
                                 height: Int(config.height),
                                 restore_faces: config.face, negative_prompt: config.npromptPrefix + negative_prompt, sampler_index: config.sampler
    )
    guard let uploadData = try? JSONEncoder().encode(payload) else {
        return
    }
    
    let url = URL(string: getApiUrl() + "/sdapi/v1/txt2img")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            errorHandler("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            //            print(response)
            print ("server error")
            errorHandler("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            //            print ("got data: \(dataString)")
            let decoder = JSONDecoder()
            let result = try! decoder.decode(txt2imgResponse.self, from: data)
            print(result.info)
            //            let resultImages = base642UIImage(base64String: result.images[0])
            let resultImages = result.images.map {
                let decodedImg = base642UIImage(base64String: $0)
                if let decodedImg = decodedImg {
                    return decodedImg
                } else {
                    print("failed to decode base64 image")
                    return UIImage(ciImage: CIImage.empty())
                }
            }
            handler(resultImages)
        }
    }
    task.resume()
    
}

func img2img(inputImg: UIImage, prompt:String , negative_prompt:String, handler: @escaping ImageGenerationHandler, errorHandler: @escaping ErrorHandler) {
    let config = sdConfig()
    let inputImg = inputImg.resizeToFitPixels(maxPixels: config.width * config.height)
    guard let inputImg = inputImg else {
        errorHandler("resize image failed")
        return
    }
    let base64Img = UIImage2dataurl(inputImg)
    guard let base64Img = base64Img else {
        print("encode image failed")
        return }
//    print("base64:\(base64Img)")
//    let base64ImgPrefix = "data:image/jpeg;base64,"
    
    let payload = img2imgPayload(init_images: [base64Img],
                                 resize_mode: config.resizeMethod,
                                 denoising_strength: config.denoiseStrength,
                                 prompt: config.promptPrefix + prompt, seed: config.seed, batch_size: Int(config.batchSize), n_iter: Int(config.batchCount),
                                 steps: Int(config.steps),
                                 cfg_scale: config.cfgScale, width: Int(config.width),
                                 height: Int(config.height),
                                 restore_faces: config.face, negative_prompt: config.npromptPrefix + negative_prompt, sampler_index: config.sampler
    )
    guard let uploadData = try? JSONEncoder().encode(payload) else {
        return
    }
    
    let url = URL(string: getApiUrl() + "/sdapi/v1/img2img")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            errorHandler("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            //            print(response)
            print ("server error")
            errorHandler("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            //            print ("got data: \(dataString)")
            let decoder = JSONDecoder()
            let result = try! decoder.decode(txt2imgResponse.self, from: data)
//            print(result.info)
            //            let resultImages = base642UIImage(base64String: result.images[0])
            let resultImages = result.images.map {
                let decodedImg = base642UIImage(base64String: $0)
                if let decodedImg = decodedImg {
                    return decodedImg
                } else {
                    print("failed to decode base64 image")
                    return UIImage(ciImage: CIImage.empty())
                }
            }
            handler(resultImages)
        }
    }
    task.resume()
    
}

typealias InterrogateHandler = (_ result: String) -> Void
func interrogate(inputImg: UIImage, handler: @escaping InterrogateHandler, errorHandler: @escaping ErrorHandler) {
    let inputImg = inputImg.resizeToFitPixels(maxPixels: 512 * 512)
    guard let inputImg = inputImg else {
        errorHandler("resize image failed")
        return
    }
    let base64Img = UIImage2dataurl(inputImg)
    guard let base64Img = base64Img else {
        print("encode image failed")
        return }
//    print("base64:\(base64Img)")
//    let base64ImgPrefix = "data:image/jpeg;base64,"
    let payload = interrogatePayload(image: base64Img)
    guard let uploadData = try? JSONEncoder().encode(payload) else {
        return
    }
    
    let url = URL(string: getApiUrl() + "/sdapi/v1/interrogate")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            errorHandler("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            //            print(response)
            print ("server error")
            errorHandler("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            //            print ("got data: \(dataString)")
//            print(dataString)

            let decoder = JSONDecoder()
            let result = try! decoder.decode(interrogateResponse.self, from: data)
            handler(result.caption)
        }
    }
    task.resume()
    
}

typealias SdmodelsHandler = (_ result: [sdmodelsResponse]) -> Void

func sdmodels(_ handler: @escaping SdmodelsHandler) async {
    let url = URL(string: getApiUrl() + "/sdapi/v1/sd-models")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            //            self.handleClientError(error)
            print ("error: \(error)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            //            self.handleServerError(response)
            print ("server error")
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "application/json",
           let data = data,
           let string = String(data: data, encoding: .utf8) {
            let decoder = JSONDecoder()
            let result = try! decoder.decode([sdmodelsResponse].self, from: data)
            print(result)
            handler(result)
        }
    }
    task.resume()
    
}

func setModel(_ modelCkpt: String) async {
    let payload = modelsPayload(sd_model_checkpoint: modelCkpt)
    guard let uploadData = try? JSONEncoder().encode(payload) else {
        return
    }
    
    let url = URL(string: getApiUrl() + "/sdapi/v1/options")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            //            print(response)
            print ("server error")
            print(response)
            return
        }
    }
    task.resume()
}

func interrupt() {
    struct emptyPayload: Codable {
    }
    let payload = emptyPayload()
    guard let uploadData = try? JSONEncoder().encode(payload) else {
        return
    }
    
    let url = URL(string: getApiUrl() + "/sdapi/v1/interrupt")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            //            print(response)
            print ("server error")
            print(response)
            return
        }
    }
    task.resume()
}

typealias SamplersHandler = (_ result: [samplersResponse]) -> Void
func samplers(_ handler: @escaping SamplersHandler) async {
    let url = URL(string: getApiUrl() + "/sdapi/v1/samplers")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            //            self.handleClientError(error)
            print ("error: \(error)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            //            self.handleServerError(response)
            print ("server error")
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "application/json",
           let data = data,
           let string = String(data: data, encoding: .utf8) {
            let decoder = JSONDecoder()
            let result = try! decoder.decode([samplersResponse].self, from: data)
            print(result)
            handler(result)
        }
    }
    task.resume()
    
}

typealias ProgressHandler = (_ result: progressResponse) -> Void

func progress(_ handler: @escaping ProgressHandler) {
    let url = URL(string: getApiUrl() + "/sdapi/v1/progress")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            //            self.handleClientError(error)
            print ("error: \(error)")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            //            self.handleServerError(response)
            print ("server error")
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "application/json",
           let data = data,
           let string = String(data: data, encoding: .utf8) {
            let decoder = JSONDecoder()
            let result = try! decoder.decode(progressResponse.self, from: data)
            print(result)
            handler(result)
        }
    }
    task.resume()
    
}
