//
//  sliderView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct sliderView: View {
    var title: String
    var sliderStep: Double
    var min: Double
    var max: Double
    @Binding var value: Double
    var body: some View {
        VStack {
            HStack {
                Text("\(title)")
                Spacer()
                Text(value,format: .number)
                    .foregroundColor(.accentColor)
            }
                Slider(
                    value: $value,
                    in: min...max,
                    step: sliderStep
                )
            
        }
    }
}

struct sliderView_Previews: PreviewProvider {
    static var previews: some View {
        sliderView(title: "test", sliderStep: 1,min: 0,max: 150, value: .constant(1))
    }
}
