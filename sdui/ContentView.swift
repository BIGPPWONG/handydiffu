//
//  ContentView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var showalert: Bool = false
    var body: some View {
        NavigationView {
            TabView {
                txt2imgView()
                    .tabItem {
                        Label("Txt2Img", systemImage: "text.alignleft")
                    }
                img2imgView()
                    .tabItem {
                        Label("Img2Img", systemImage: "text.below.photo")
                    }
                interrogateView()
                    .tabItem {
                        Label("Interrogate", systemImage: "cube.transparent")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
