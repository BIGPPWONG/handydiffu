//
//  ContentView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct interrogateView: View {
    @State var images: [UIImage] = [UIImage(ciImage: CIImage.empty())]
    @State var isProgressing = false
    @State var prompt:String = ""
    @State var errMsg: String = ""
    @State var showAlert: Bool = false
//    @State var inputImg: UIImage = UIImage(ciImage: CIImage.empty())
    @State var inputImgisUploaded: Bool = false
    @State var isAddingPhoto: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.gray.opacity(0.1)
                    if inputImgisUploaded {
                        TabView {
                            ForEach(Array(zip(images.indices, images)), id: \.0) { index, img in
                              // index and item are both safe to use here
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .tag(index)
                            }
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
                .overlay(alignment: .bottomTrailing) {
                    Button("Clear") {
                        images = [UIImage(ciImage: CIImage.empty())]
                        inputImgisUploaded = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                VStack {
                    Text("Interrogated Prompt")
                    Divider()
                    ScrollView {
                        Text(prompt)
                    }
                    Divider()
            
                    HStack {
                        Button {
                            Task {
                                await makePrediction()
                            }
                        } label: {
                            Text("Interrogate")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isProgressing || !inputImgisUploaded)
                        Button {
                            Task {
                            
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = prompt
                            }
                        } label: {
                            Text("Copy to Clipboard")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isProgressing)
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
    }
}

extension interrogateView {
    func interrogateHanlder(_ result: String) {
        prompt = result
        isProgressing = false
        //        print(result)
    }
    func errorHanlder(_ msg: String) {
        errMsg = msg
        showAlert = true
        isProgressing = false
        //        self.images = resultImg
    }
    func makePrediction() {
        isProgressing = true
        interrogate(inputImg: images[0], handler: interrogateHanlder, errorHandler: errorHanlder)
        
    }
}

struct interrogateView_Previews: PreviewProvider {
    static var previews: some View {
        interrogateView()
    }
}
