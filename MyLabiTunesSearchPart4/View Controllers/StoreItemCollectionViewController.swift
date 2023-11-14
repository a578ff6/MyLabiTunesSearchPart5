//
//  StoreItemCollectionViewController.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

import UIKit

// private let reuseIdentifier = "collectionViewItemCell"

class StoreItemCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 每個項目的間距
        let spacing: CGFloat = 8
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitem: item,
            count: 3
        )
        
        let section = NSCollectionLayoutSection(group: group)
        /// 為區段設置內容邊距。
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        /// 設置群組之間的間距。
        section.interGroupSpacing = spacing
        // 將集合視圖的佈局設置為創建的組合式佈局。
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
}


