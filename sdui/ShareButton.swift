//
//  ShareButton.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/25.
//

import SwiftUI

struct ShareButton: View {
    var shareItems: [Any]
    var body: some View {
        Button {
            let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }
            if let windowScene = scene as? UIWindowScene {
                activityController.popoverPresentationController?.sourceView = windowScene.keyWindow
                activityController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width*0.99, y: 0, width: 1, height: 1)
                windowScene.keyWindow?.rootViewController?.present(activityController, animated: true, completion: nil)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton(shareItems: [""])
    }
}
