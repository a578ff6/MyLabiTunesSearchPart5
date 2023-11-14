//
//  StoreItem.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

/*
import Foundation

/*
 使用了自訂的 CodingKeys 和 AdditionalKeys 來處理 JSON 鍵與結構體屬性之間可能存在的不匹配問題。
 自訂初始化方法 init(from decoder: Decoder) 則用於從解碼器容器中提取數據並賦值給對應屬性。
 */

/// 用於解析搜尋回應
struct SearchResponse: Codable {
    /// 存儲從 iTunes API 獲得的項目陣列
    let results: [StoreItem]
}

/// 代表商店中的單一項目
struct StoreItem: Codable {
    let name: String
    let artist: String
    var kind: String
    var description: String
    var artworkURL: URL
    let trackId: Int?
    let collectionId: Int?
    
    // 自訂映射 JSON 鍵與struct屬性之間的關係
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case description = "longDescription"
        case artworkURL = "artworkUrl100"
        case trackId
        case collectionId
    }
    
    // 額外自訂鍵，用於處理可能出現的其他 JSON 鍵
    enum AdditionalKeys: String, CodingKey {
        case description = "shortDescription"
        case collectionName = "collectionName"
    }
    
    // 自訂的初始化方法，用於解碼
    init(from decoder: Decoder) throws {
        // 創建一個解碼器的容器，用指定的鍵類型
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解碼並賦值給對應的屬性
        self.artist = try container.decode(String.self, forKey: .artist)
        self.kind = (try? container.decode(String.self, forKey: .kind)) ?? ""
        self.artworkURL = try container.decode(URL.self, forKey: .artworkURL)
        self.trackId = try? container.decode(Int.self, forKey: .trackId)
        self.collectionId = try? container.decode(Int.self, forKey: .collectionId)
        
        // 創建另一個解碼器的容器，用於處理額外的鍵
        let additionalContainer = try decoder.container(keyedBy: AdditionalKeys.self)
        
        // 優先使用主要容器的數據，如果無法獲得則嘗試從額外容器獲取，最後賦予預設值
        self.name = (try? container.decode(String.self, forKey: .name)) ?? (try? additionalContainer.decode(String.self, forKey: .collectionName)) ?? "--"
        self.description = (try? container.decode(String.self, forKey: .description)) ?? (try? additionalContainer.decode(String.self, forKey: .description)) ?? "--"
    }
}
*/


// MARK: - 練習部分

import Foundation

/*
 使用了自訂的 CodingKeys 和 AdditionalKeys 來處理 JSON 鍵與結構體屬性之間可能存在的不匹配問題。
 自訂初始化方法 init(from decoder: Decoder) 則用於從解碼器容器中提取數據並賦值給對應屬性。
 */

/// 用於解析搜尋回應
struct SearchResponse: Codable {
    /// 存儲從 iTunes API 獲得的項目陣列
    let results: [StoreItem]
}

/// 代表商店中的單一項目
struct StoreItem: Codable, Hashable {
    let name: String
    let artist: String
    var kind: String
    var description: String
    var artworkURL: URL
    let trackId: Int?
    let collectionId: Int?
    
    // 自訂映射 JSON 鍵與struct屬性之間的關係
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case description = "longDescription"
        case artworkURL = "artworkUrl100"
        case trackId
        case collectionId
    }
    
    // 額外自訂鍵，用於處理可能出現的其他 JSON 鍵
    enum AdditionalKeys: String, CodingKey {
        case description = "shortDescription"
        case collectionName = "collectionName"
    }
    
    // 自訂的初始化方法，用於解碼
    init(from decoder: Decoder) throws {
        // 創建一個解碼器的容器，用指定的鍵類型
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解碼並賦值給對應的屬性
        self.artist = try container.decode(String.self, forKey: .artist)
        self.kind = (try? container.decode(String.self, forKey: .kind)) ?? ""
        self.artworkURL = try container.decode(URL.self, forKey: .artworkURL)
        self.trackId = try? container.decode(Int.self, forKey: .trackId)
        self.collectionId = try? container.decode(Int.self, forKey: .collectionId)
        
        // 創建另一個解碼器的容器，用於處理額外的鍵
        let additionalContainer = try decoder.container(keyedBy: AdditionalKeys.self)
        
        // 優先使用主要容器的數據，如果無法獲得則嘗試從額外容器獲取，最後賦予預設值
        self.name = (try? container.decode(String.self, forKey: .name)) ?? (try? additionalContainer.decode(String.self, forKey: .collectionName)) ?? "--"
        self.description = (try? container.decode(String.self, forKey: .description)) ?? (try? additionalContainer.decode(String.self, forKey: .description)) ?? "--"
    }
}

