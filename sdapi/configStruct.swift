//
//  configStruct.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/25.
//

import Foundation
import SwiftUI

struct sdConfig {
    @AppStorage("steps") var steps = 20.0
    @AppStorage("width") var width = 512.0
    @AppStorage("height") var height = 512.0
    @AppStorage("batchCount") var batchCount = 1.0
    @AppStorage("batchSize") var batchSize = 1.0
    @AppStorage("cfgScale") var cfgScale = 1.0
    @AppStorage("seed") var seed:Int = -1
    @AppStorage("checkpoint") var checkpoint:String = ""
    @AppStorage("promptPrefix") var promptPrefix: String = ""
    @AppStorage("npromptPrefix") var npromptPrefix: String = ""
    @AppStorage("sampler") var sampler: String = "Euler"
    @AppStorage("face") var face: Bool = false
    @AppStorage("highres") var highres: Bool = false
    @AppStorage("denoiseStrength") var denoiseStrength = 0.8
    @AppStorage("resizemethod") var resizeMethod: Int = 0

}

