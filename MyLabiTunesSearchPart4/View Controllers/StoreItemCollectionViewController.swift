//
//  StoreItemCollectionViewController.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/13.
//

import UIKit

// private let reuseIdentifier = "collectionViewItemCell"

/*
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
*/

// MARK: - 更新集合視圖的排版

/*
class StoreItemCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 將StoreItemCollectionViewSectionHeader註冊為集合視圖的補充視圖，用於顯示各個部分的標頭。"Header" 是視圖類型的標識符。
        collectionView.register(StoreItemCollectionViewSectionHeader.self, forSupplementaryViewOfKind: "Header", withReuseIdentifier: StoreItemCollectionViewSectionHeader.reuseIdentifier)
    }
    
    /// 配置集合視圖（Collection View）的布局
    func configureCollectionViewLayout(for searchScope: SearchScope) {
        // 定義每個項目的大小，寬度是其群組寬度的三分之一，高度是自適應的
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = .init(top: 8, leading: 5, bottom: 8, trailing: 5)  // 設置項目的邊距
        
        // 創建水平方向的群組，其中包含一個項目，群組的寬度是其父容器寬度的三分之一，高度是166點
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .absolute(166)), subitem: item, count: 1)
        
        // 定義一個布局的區段，包含之前定義的群組
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary   // 設定區段的滾動行為為橫向連續滾動
        
        // 定義 header 視圖的大小和類型
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        let headeritem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "Header", alignment: .topLeading)
        
        section.boundarySupplementaryItems = [headeritem]   // 加入頭部視圖到區段
        
        // 創建一個組合式布局，並設置到集合視圖上
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
}
*/


// MARK: - 微調整合

class StoreItemCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 將StoreItemCollectionViewSectionHeader註冊為集合視圖的補充視圖，用於顯示各個部分的標頭。"Header" 是視圖類型的標識符。
        collectionView.register(StoreItemCollectionViewSectionHeader.self, forSupplementaryViewOfKind: "Header", withReuseIdentifier: StoreItemCollectionViewSectionHeader.reuseIdentifier)
    }
    
    /// 配置集合視圖（Collection View）的布局
    func configureCollectionViewLayout(for searchScope: SearchScope) {
        // 定義每個項目的大小，寬度是其群組寬度的三分之一，高度是自適應的
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = .init(top: 8, leading: 5, bottom: 8, trailing: 5)  // 設置項目的邊距
        
        // 創建水平方向的群組，其中包含一個項目，群組的寬度是其父容器寬度的三分之一，高度是166點
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: searchScope.groupWidthDimension, heightDimension: .absolute(166)), subitem: item, count: searchScope.groupItemCount)
        
        // 定義一個布局的區段，包含之前定義的群組
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = searchScope.orthogonalScrollingBehavior   // 設定區段的滾動行為為橫向連續滾動
        
        // 定義 header 視圖的大小和類型
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        let headeritem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "Header", alignment: .topLeading)
        
        section.boundarySupplementaryItems = [headeritem]   // 加入頭部視圖到區段
        
        // 創建一個組合式布局，並設置到集合視圖上
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

}

// MARK: - 擴展 SearchScope
extension SearchScope {
    
    /// 根據搜索範圍定義橫向滾動行為
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch self {
        case .all:
            return .continuousGroupLeadingBoundary
        default:
            return .none
        }
    }
    
    /// 定義群組內項目的數量
    var groupItemCount: Int {
        switch self {
        case .all:
            return 1    // 只有一個項目
        default:
            return 3    // 預設為三個項目
        }
    }
    
    /// 定義群組的寬度
    var groupWidthDimension: NSCollectionLayoutDimension {
        switch self {
        case .all:
            return .fractionalWidth(1/3)    // 寬度為父容器的三分之一
        default:
            return .fractionalWidth(1.0)    // 寬度為父容器的整體寬度
        }
    }
}

