//
//  txtConfigView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct txtConfigView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var seedStr: String = "-1"
    @State private var allckpt:[String] = []
    @State private var allsamplers:[String] = []
    @AppStorage("steps") var steps = 20.0
    @AppStorage("width") var width = 512.0
    @AppStorage("height") var height = 512.0
    @AppStorage("batchCount") var batchCount = 1.0
    @AppStorage("batchSize") var batchSize = 1.0
    @AppStorage("cfgScale") var cfgScale = 1.0
    @AppStorage("seed") var seed:Int = -1
    @AppStorage("checkpoint") var checkpoint:String = ""
    @AppStorage("sampler") var sampler: String = "Euler"
    @AppStorage("promptPrefix") var promptPrefix: String = ""
    @AppStorage("npromptPrefix") var npromptPrefix: String = ""
    @AppStorage("denoiseStrength") var denoiseStrength = 0.8
    @AppStorage("resizemethod") var resizeMethod: Int = 0
    var body: some View {
        NavigationView {
        Form {
            Picker("Stable Diffusion checkpoint", selection: $checkpoint) {
                ForEach(allckpt, id: \.self) { ckpt in
                    Text("\(ckpt)")
                }
                
            }
            .onAppear {
                Task {
                    await sdmodels(sdmodelsHanlder)
                }
            }
            .onChange(of: checkpoint) { _ in
                Task {
                    await setModel(checkpoint)
                }
            }
            Section("Prefix") {
                HStack {
                    Text("Prompt")
                    TextField(
                        "Prompt Prefix",
                        text: $promptPrefix
                    )
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Negative")
                    TextField(
                        "Negative Prefix",
                        text: $npromptPrefix
                    )
                    .multilineTextAlignment(.trailing)
                }
            }
            Section {
                Picker("Sampler", selection: $sampler) {
                    ForEach(allsamplers, id: \.self) { spl in
                        Text("\(spl)")
                    }
                    
                }
                .onAppear {
                    Task {
                        await samplers(samplersHanlder)
                    }
                }
                sliderView(title: "Steps",sliderStep: 1, min: 1,max: 150 ,value: $steps)
            }
            Section {
                sliderView(title: "Width",sliderStep: 64, min: 64,max: 2048 ,value: $width)
                sliderView(title: "Height",sliderStep: 64, min: 64,max: 2048 ,value: $height)
            }
            Section {
                sliderView(title: "Batch Count",sliderStep: 1, min: 1,max: 100 ,value: $batchCount)
                sliderView(title: "Batch Size",sliderStep: 1, min: 1,max: 8 ,value: $batchSize)
            }
            Section {
                sliderView(title: "CFG Scale",sliderStep: 0.5, min: 1,max: 30 ,value: $cfgScale)
            }
            Section("Img2Img Specific Settings") {
                Picker("Resize", selection: $resizeMethod) {
                    Text("Just resize").tag(0)
                    Text("Crop resize").tag(1)
                    Text("Resize fill").tag(2)
                }.pickerStyle(.segmented)
                sliderView(title: "Denoising strength",sliderStep: 0.01, min: 0,max: 1 ,value: $denoiseStrength)
            }
            HStack {
                Text("Seed")
                TextField(
                    "Seed",
                    text: $seedStr
                )
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .onSubmit {
                    seed = Int(seedStr) ?? -1
                    seedStr = String(seed)
                }
            }
            
        }
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
}
    }
}

struct txtConfigView_Previews: PreviewProvider {
    static var previews: some View {
        txtConfigView()
    }
}

extension txtConfigView {
    func sdmodelsHanlder(_ result: [sdmodelsResponse]) -> Void {
        allckpt = result.map {
            $0.title
        }
    }
    func samplersHanlder(_ result: [samplersResponse]) -> Void {
        allsamplers = result.map {
            $0.name
        }
    }
}
