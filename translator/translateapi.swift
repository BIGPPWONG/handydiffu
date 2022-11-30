//
//  translateapi.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/27.
//

import Foundation
import MLKit
import SwiftUI

class translator {
    
    // Create an English-German translator:
    let languageTranslator: Translator
    init() {
        @AppStorage("sourceLang") var sourceLang: String = "zh"
        print(sourceLang)
        let sourcelang = TranslateLanguage(rawValue: sourceLang)
        let options = TranslatorOptions(sourceLanguage: sourcelang, targetLanguage: .english)
        languageTranslator = Translator.translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )
        languageTranslator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }

            // Model downloaded successfully. Okay to start translating.
            print("Model downloaded successfully. Okay to start translating.")
        }
    }
}
