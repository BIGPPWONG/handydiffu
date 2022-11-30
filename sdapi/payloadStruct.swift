//
//  payloadStruct.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import Foundation

struct interrogatePayload: Codable {
    var image: String
    var model: String = "clip"
}

struct txt2imgPayload: Codable {
//    let customerId: String
//    let items: [String]
    var enable_hr = false
    var denoising_strength = 0
    var firstphase_width = 0
    var firstphase_height = 0
    var prompt = ""
    var styles: [String] = [""]
    var seed = -1
    var subseed = -1
    var subseed_strength = 0
    var seed_resize_from_h = -1
    var seed_resize_from_w = -1
    var batch_size = 1
    var n_iter = 1
    var steps = 50
    var cfg_scale = 12.0
    var width = 512
    var height = 512
    var restore_faces = false
    var tiling = false
    var negative_prompt = ""
    var eta = 0
    var s_churn = 0
    var s_tmax = 0
    var s_tmin = 0
    var s_noise = 1
//    "override_settings": {},
    var sampler_index:String = "Euler"
}

struct img2imgPayload: Codable {
    var init_images: [String]
    var resize_mode = 0
    var denoising_strength = 0.75
//    var mask = ""
//    var mask_blur = 4
    var inpainting_fill = 0
    var inpaint_full_res = true
    var inpaint_full_res_padding = 0
    var inpainting_mask_invert = 0
    var prompt = ""
    var styles: [String] = [""]
    var seed = -1
    var subseed = -1
    var subseed_strength = 0
    var seed_resize_from_h = -1
    var seed_resize_from_w = -1
    var batch_size = 1
    var n_iter = 1
    var steps = 50
    var cfg_scale = 12.0
    var width = 512
    var height = 512
    var restore_faces = false
    var tiling = false
    var negative_prompt = ""
    var eta = 0
    var s_churn = 0
    var s_tmax = 0
    var s_tmin = 0
    var s_noise = 1
//    "override_settings": {},
    var sampler_index = "Euler"
    var include_init_images = false
}

struct modelsPayload: Codable {
    var sd_model_checkpoint: String
}
