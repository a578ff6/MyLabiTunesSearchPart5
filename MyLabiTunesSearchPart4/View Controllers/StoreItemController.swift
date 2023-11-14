//
//  StoreItemController.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

import Foundation
import UIKit

/// 處理商店項目請求的類別
class StoreItemController {
    enum StoreItemError: Error, LocalizedError {
        case itemsNotFound
        case imageDataMissing
    }
    
    /// 用於根據查詢條件從 iTunes API 獲取項目
    func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = query.map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.itemsNotFound
        }
        
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        return searchResponse.results
    }
    
    /// 用於從指定的 URL 獲取圖片
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else {
            throw StoreItemError.imageDataMissing
        }
        
        return image
        
    }
    
}

