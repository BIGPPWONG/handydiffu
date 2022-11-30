//
//  supportedLanguage.swift
//  sdui
//
//  Created by 黄伟文 on 2022/11/27.
//

import Foundation
import MLKit

enum SupportedLanguage: String, CaseIterable, Identifiable {
    case af
    case ar
    case be
    case bg
    case bn
    case ca
    case cs
    case cy
    case da
    case de
    case el
//    case en
    case eo
    case es
    case et
    case fa
    case fi
    case fr
    case ga
    case gl
    case gu
    case he
    case hi
    case hr
    case ht
    case hu
    case id
//    case is
    case it
    case ja
    case ka
    case kn
    case ko
    case lt
    case lv
    case mk
    case mr
    case ms
    case mt
    case nl
    case no
    case pl
    case pt
    case ro
    case ru
    case sk
    case sl
    case sq
    case sv
    case sw
    case ta
    case te
    case th
    case tl
    case tr
    case uk
    case ur
    case vi
    case zh
    var id: Self { self }
}

