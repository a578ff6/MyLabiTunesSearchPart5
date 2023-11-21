//
//  SearchScope.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/20.
//

import Foundation
import UIKit

/// 表示不同的搜尋範圍。
enum SearchScope: CaseIterable {
    /// Enum 的各個條件：all、movies、music、apps和books
    case all, movies, music, apps, books
    
    /// 根據不同的搜尋範圍，返回相對應的 String。
    var title: String {
        switch self {
        case .all: 
            return "All"
        case .movies:
            return "Movies"
        case .music:
            return "Music"
        case .apps:
            return "Apps"
        case .books:
            return "Books"
        }
    }
    
    /// 根據不同的搜尋範圍，返回用於 API 查詢的媒體類型。
    var mediaType: String {
        switch self {
        case .all:
            return "all"
        case .movies:
            return "movie"
        case .music:
            return "music"
        case .apps:
            return "software"
        case .books:
            return "ebook"
        }
    }
}
