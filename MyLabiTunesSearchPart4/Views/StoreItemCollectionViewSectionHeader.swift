//
//  StoreItemCollectionViewSectionHeader.swift
//  MyLabiTunesSearchPart4
//
//  Created by 曹家瑋 on 2023/11/21.
//

import UIKit

class StoreItemCollectionViewSectionHeader: UICollectionReusableView {
    
    /// 用來辨認重用的標識
    static let reuseIdentifier = "StoreItemCollectionViewSectionHeader"
    
    /// 標題Label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 17)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// 設定標題文字
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    // 設定視圖的佈局和樣式
    private func setupView() {
        
        backgroundColor = .systemGray5

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
        ])
    }
}
