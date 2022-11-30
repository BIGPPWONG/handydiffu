//
//  responseStruct.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import Foundation
struct txt2imgResponse: Codable {
    var images: [String]
//    var parameters: [String:Int] = ["test" : 0]
    var info: String
    enum CodingKeys: String, CodingKey {
        case images
//        case parameters = ["test" : 0]
        case info
       }
}

struct sdmodelsResponse: Codable {
    var title: String
//        "model_name": "string",
//        "hash": "string",
//        "filename": "string",
//        "config": "string"
}

struct progressResponse: Codable {
    var progress: Double
    var eta_relative: Double
}

struct samplersResponse: Codable {
    var name: String
}

struct interrogateResponse: Codable {
    var caption: String
}

