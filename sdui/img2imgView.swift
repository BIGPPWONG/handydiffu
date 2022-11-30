//
//  ContentView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct img2imgView: View {
    @State var images: [UIImage] = [UIImage(ciImage: CIImage.empty())]
    @State var isProgressing = false
    @State var progressPercentage: Double = 0.0
    @State var etaRelative: Double = 0.0
    @State var prompt:String = ""
    @State var negative_prompt: String = ""
    @State var showAdvance: Bool = false
    @AppStorage("face") var face: Bool = false
    @AppStorage("highres") var highres: Bool = false
    @State var errMsg: String = ""
    @State var showAlert: Bool = false
//    @State var inputImg: UIImage = UIImage(ciImage: CIImage.empty())
    @State var inputImgisUploaded: Bool = false
    @State var isAddingPhoto: Bool = false
    @AppStorage("enableTranslator") var enableTranslator: Bool = false
    @State var selectedTab: Int = 0
    @State var hideControl = false
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.gray.opacity(0.1)
                    if inputImgisUploaded {
                        TabView(selection: $selectedTab) {
                            ForEach(Array(zip(images.indices, images)), id: \.0) { index, img in
                              // index and item are both safe to use here
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .tag(index)
                            }
//                            ForEach(images,id: \.self) { img in
//                                Image(uiImage: img)
//                                    .resizable()
//                                    .scaledToFit()
//                            }
                        }.tabViewStyle(.page)
                    } else {
                        Button {
                            isAddingPhoto = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                Text("Select Input")
                            }
                        }.buttonStyle(.bordered)
                            .sheet(isPresented: $isAddingPhoto) {
                                PhotoPicker(inputImg: $images, result: $inputImgisUploaded)
                            }
                    }
                }
                .onTapGesture {
                    hideControl.toggle()
                }
                .overlay(alignment: .bottomTrailing) {
                    Button("Clear") {
                        images = [UIImage(ciImage: CIImage.empty())]
                        inputImgisUploaded = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                if !hideControl {
                    VStack {
                        ProgressView(value: progressPercentage,total: 1.0) {
                            HStack {
                                Text("\(progressPercentage*100, specifier: "%.0f")%")
                                Spacer()
                                Text("\(etaRelative, specifier: "%.0f")s")
                            }
                        }
                        Divider()
                        //                Group {
                        TextField("Prompt", text: $prompt)
                        Divider()
                        TextField("Negative Prompt", text: $negative_prompt)
                        Divider()
                        //                }
                        //                .listStyle(.plain)
                        //                .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Toggle("Face", isOn: $face)
                            Spacer()
                            Button("Advance") {
                                showAdvance.toggle()
                            }
                        }
                        .toggleStyle(.button)
                        .buttonStyle(.borderedProminent )
                        .sheet(isPresented: $showAdvance) {
                            txtConfigView()
                            
                        }
                        Divider()
                        Group {
                            Share2PixAIButton(shareItems: images[selectedTab])
                            Divider()
                        }
                        HStack {
                            Button {
                                Task {
                                    await makePrediction()
                                }
                            } label: {
                                Text("Generate")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(isProgressing || !inputImgisUploaded)
                            Button {
                                Task {
                                    interrupt()
                                    isProgressing = false
                                }
                            } label: {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(!isProgressing)
                        }
                        .buttonStyle(.borderedProminent)
                        //                .font(.title3)
                    }
                    .padding()
                    .alert(errMsg, isPresented: $showAlert){
                        Button("OK", role: .cancel) { }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareButton(shareItems: [images[selectedTab]])
                }
                
            }
        }
    }
}

extension img2imgView {
    
    func sdHanlder(_ resultImg: [UIImage]) {
        self.images = resultImg
        isProgressing = false
    }
    func modelsHanlder(_ result: [sdmodelsResponse]) {
        //        self.images = resultImg
    }
    func progressHanlder(_ result: progressResponse) {
        progressPercentage = result.progress
        etaRelative = result.eta_relative
        //        print(result)
    }
    func errorHanlder(_ msg: String) {
        errMsg = msg
        showAlert = true
        isProgressing = false
        //        self.images = resultImg
    }
    func makePrediction() {
        let concurrentQueue = DispatchQueue(label: "swiftlee.concurrent.queue", attributes: .concurrent)
        isProgressing = true
        concurrentQueue.async {
            var prompt_in: String = prompt
            var negative_prompt_in: String = negative_prompt
            if enableTranslator {
                let translator = translator()
                translator.languageTranslator.translate(prompt) { translatedText, error in
                    guard error == nil, let translatedText = translatedText else {
                        return }
                    prompt_in = translatedText
                    translator.languageTranslator.translate(negative_prompt) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else {
                            return }
                        negative_prompt_in = translatedText
                        print("prompt: \(prompt_in),\(negative_prompt_in)")
                        img2img(inputImg: images[0], prompt: prompt_in, negative_prompt: negative_prompt_in,handler: sdHanlder,errorHandler: errorHanlder)
                    }
                }
            } else {
                img2img(inputImg: images[0], prompt: prompt_in, negative_prompt: negative_prompt_in,handler: sdHanlder,errorHandler: errorHanlder)
            }
            
        }
        //        async let _ = txt2img(sdHanlder)
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            concurrentQueue.async() {
                if isProgressing == false {
                    timer.invalidate()
                }
                print("Timer fired!")
                progress(progressHanlder)
            }
        }
        print("finish")
        
    }
}

struct img2imgView_Previews: PreviewProvider {
    static var previews: some View {
        img2imgView()
    }
}
