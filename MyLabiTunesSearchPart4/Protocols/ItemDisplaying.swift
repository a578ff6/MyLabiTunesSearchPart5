//
//  ItemDisplaying.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/14.
//

import Foundation
import UIKit

/// 根據表格視圖、集合視圖，設置 ItemDisplaying 的協議，包含三個 UIImageView 和 UILabel 屬性。
protocol ItemDisplaying {
    var itemImageView: UIImageView! { get set }
    var titleLabel: UILabel! { get set }
    var detailLabel: UILabel! { get set }
}

// 使用 @MainActor 擴展 ItemDisplaying 協議，確保所有 UI 更新在主執行緒上執行。
@MainActor
extension ItemDisplaying {
    
    // 異步函數 configure，用於配置接收的 item 以及 storeItemController。
    func configure(for item: StoreItem, storeItemController: StoreItemController) async {
        titleLabel.text = item.name
        detailLabel.text = item.artist
        // 預設圖片，等待實際圖片加載完成後替換
        itemImageView.image = UIImage(systemName: "photo")
        
        do {
            // 嘗試加載並顯示實際圖片
            let image = try await storeItemController.fetchImage(from: item.artworkURL)
            self.itemImageView.image = image
        } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            // 處理被取消的請求，這裡沒有進行任何操作。
        } catch {
            // 若發生其他錯誤
            self.itemImageView.image = UIImage(systemName: "photo")
            print("Error fetching image: \(error)")
        }
    }
}


