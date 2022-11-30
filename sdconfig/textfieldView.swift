//
//  textfieldView.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/24.
//

import SwiftUI

struct textfieldView: View {
    var title: String
    @Binding var value: String
    @State var tmpvalue: String = ""
    var verifyFunc: (String) -> Bool = { str in
        return true }
    var keyboardType = UIKeyboardType.default
    var body: some View {
        HStack {
            Text("\(title)")
            TextField(
                title,
                text: $value
            )
            .onAppear {
                tmpvalue = value
            }
            .multilineTextAlignment(.trailing)
            .keyboardType(keyboardType)
            .onSubmit {
                if verifyFunc(value) {
//                    print("verfied successed")
//                    value = tmpvalue
                } else {
                    print("verfied failed")
                    value = tmpvalue
                }
                
            }
        }
    }
}

//struct textfieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        textfieldView()
//    }
//}
