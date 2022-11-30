//
//  SettingsView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI
import MLKit

struct SettingsView: View {
    @AppStorage("apiurl") var apiUrl: String = "http://192.168.4.121:7860"
    @AppStorage("username") var username: String = ""
    @AppStorage("password") var password: String = ""
    @AppStorage("enableTranslator") var enableTranslator: Bool = false
    @AppStorage("sourceLang") var sourceLang: String = "zh"
    @State private var tmpapiUrl: String = ""
    @State private var showingAlert = false
    @State private var testResult = "Success"
    @State private var isTesting = false
    @State private var isDownloading = false
    @State private var downloadResult = false
    @State private var downloadAlert = false
//    @State private var showPopover = false
    var body: some View {
        List {
            Section("Server") {
                textfieldView(title: "ApiUrl", value: $apiUrl,verifyFunc: verifyUrl, keyboardType: .URL)
                textfieldView(title: "Username", value: $username)
                textfieldView(title: "Password", value: $password)
                Button {
                    Task {
                        isTesting = true
                        let url = URL(string: apiUrl)!
                        url.isReachable { result in
                            if result {
                                testResult = "Success"
                            } else {
                                testResult = "Fail"
                            }
                            print(result)
                            showingAlert = true
                            isTesting = false
                        }
                        
                    }
                } label: {
                    HStack {
                        Text("Test Connection")
                        Spacer()
                        ProgressView().opacity(isTesting ? 1 : 0)
                    }
                }
                .disabled(isTesting)
                .alert(testResult, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                
            }
            Section(header: Text("Prompt Translator"),footer: Text("Powered by ML Kit. (Prefix won't be translated.)")) {
                Toggle("Enable Prompt Translator", isOn: $enableTranslator)
                if enableTranslator {
                    Picker("Source Language", selection: $sourceLang) {
                        ForEach(SupportedLanguage.allCases) { lang in
                            Text(lang.rawValue.capitalized)
                                .tag(lang.rawValue.lowercased())
                        }
                    }
                    .onChange(of: sourceLang) { _ in
                        downloadResult = false
                    }
                    Link("View Support Languages",
                          destination: URL(string: "https://developers.google.com/ml-kit/language/translation/translation-language-support?hl=en")!)
                    
                    Button {
                        //                            showalert = true
                        Task {
                            isDownloading = true
                            let sourcelang = TranslateLanguage(rawValue: sourceLang)
                            let localModels = ModelManager.modelManager().downloadedTranslateModels
                            // Delete the German model if it's on the device.
                            let germanModel = TranslateRemoteModel.translateRemoteModel(language: sourcelang)
                            ModelManager.modelManager().deleteDownloadedModel(germanModel) { error in
                                guard error == nil else { return }
                                // Model deleted.
                            }
                            
                            let options = TranslatorOptions(sourceLanguage: sourcelang, targetLanguage: .english)
                            let translator = Translator.translator(options: options)
                            
                            let conditions = ModelDownloadConditions(
                                allowsCellularAccess: true,
                                allowsBackgroundDownloading: true
                            )
                            translator.downloadModelIfNeeded(with: conditions) { error in
                                guard error == nil else {
                                    print("Download error: \(error)")
                                    downloadAlert = true
                                    return
                                    
                                }

                                // Model downloaded successfully. Okay to start translating.
                                print("Model downloaded successfully. Okay to start translating.")
//                                downloadResult = true
                                translator.translate("一个穿着黑丝的漂亮女仆") { translatedText, error in
                                    guard error == nil, let translatedText = translatedText else {
                                        print("translate error: \(error)")
                                        downloadAlert = true
                                        return }
                                    print(translatedText)
                                    downloadResult = true
                                    //                            }
                                    isDownloading = false
                                }
                            }
                            
                        }
                    } label: {
                        HStack {
                            if downloadResult {
                                Text("Translator Downloaded!")
                            } else {
                                Text("Download Translator")
                            }
                            Spacer()
                            ProgressView().opacity(isDownloading ? 1 : 0)
                        }
                    }
                    .onAppear {
                        let sourcelang = TranslateLanguage(rawValue: sourceLang)
                        let localModels = ModelManager.modelManager().downloadedTranslateModels
                        // Delete the German model if it's on the device.
                        let germanModel = TranslateRemoteModel.translateRemoteModel(language: sourcelang)
                        downloadResult = ModelManager.modelManager().isModelDownloaded(germanModel)
                    }
                    .disabled(isDownloading||downloadResult)
                    .alert("Download failed", isPresented: $downloadAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    Button("Reset") {
                        downloadResult = false
                    }
//                    Text(isDownloading.description)
                }
                
            }
        
        }
            .animation(.default, value: enableTranslator)
//        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

func verifyUrl (_ urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}
