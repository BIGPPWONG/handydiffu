//
//  extension.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/26.
//

import Foundation
import SwiftUI

enum resizeMethod: String, CaseIterable, Identifiable {
    case resize, cropResize, resizefill
    var id: Self { self }
}

struct Share2PixAIButton: View {
    var shareItems: UIImage
    var body: some View {
        Button {
            if shareItems.size.width * shareItems.size.height > 2500 {
//                let pasteboard = UIPasteboard.general
//                pasteboard.image = shareItems
                if let image = shareItems as? UIImage {
                    if let data = image.jpegData(compressionQuality: 1.0) {
                        if let fileManager = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.huangweiwen.upscaleplayer")
                        {
                            //                                    fileManager.
                            let timestamp = NSDate().timeIntervalSince1970
                            let imageName = String(timestamp) + ".jpeg"// write your image name here
                            //                                    let ii = imageURL.lastPathComponent
                            print("imageName: \(imageName)")
                            let imageLocationUrl = fileManager.appendingPathComponent(imageName)
//                                        let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
                            try? data.write(to: imageLocationUrl)
                        }
                        
                    }
                }
                let url = URL(string: "pixai://")!
                UIApplication.shared.open(url) { (result) in
                    if result {
                        print("open url scheme success.")
                       // The URL was delivered successfully!
                    } else {
                        print("open scheme failed")
                    }
                }
            }
        } label: {
            HStack {
                Image(uiImage: UIImage(named: "pixai")!)
                    .resizable()
                    .scaledToFit()
                Text("PixAI Super Res")
//                    .fontWeight(.semibold)
            }
            .frame(maxHeight: 30, alignment: .trailing)
        }
    }
}
struct Share2PixAIButton_Previews: PreviewProvider {
    static var previews: some View {
        Share2PixAIButton(shareItems: UIImage(ciImage: CIImage.empty()))
    }
}
