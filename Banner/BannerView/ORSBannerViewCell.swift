//
//  ORSBannerViewCell.swift
//  BannerViewDemo
//
//  Created by hither on 2023/3/22.
//

import UIKit

class ORSBannerViewCell: UICollectionViewCell {
    
    // image
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// ORSBannerViewCell组件内部 private方法实现extension定义
private extension ORSBannerViewCell {
    
    // 配置UI控件布局
    private func configUI() {
        // debug only
         let random = CGFloat.random(in: 0.0...9999.0) / 10000.0
         contentView.backgroundColor = UIColor.init(white: random, alpha: random)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
