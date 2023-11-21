//
//  StoreItemTableViewDiffableDataSource.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/21.
//

import UIKit

@MainActor
class StoreItemTableViewDiffableDataSource: UITableViewDiffableDataSource<String, StoreItem> {
    
    // 將為每個表格視圖的段落（Section）提供一個標題
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // snapshot() 方法會捕捉當前數據源的狀態，進而提取對應段落的標題
        return snapshot().sectionIdentifiers[section]
    }
}
