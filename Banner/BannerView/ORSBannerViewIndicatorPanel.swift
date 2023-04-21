//
//  ORSBannerViewIndicatorPanel.swift
//  BannerViewDemo
//
//

import UIKit

class ORSBannerViewIndicatorPanel: UIView {
    
    var count: Int = 0 {
        didSet {
            updateIndicators(count: count)
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            updateSelectedIndicator(index: selectedIndex)
        }
    }
    
    var selectedColor = UIColor.init(white: 0, alpha: 1)
    
    var normalColor = UIColor.init(white: 0, alpha: 0.55)
    
    var indicatorSize  = CGSize.init(width: 16, height: 5)
    
    var indicatorSpacing: CGFloat = 4 {
        didSet {
            indicatorContainer.spacing = indicatorSpacing
        }
    }
    
    var indicatorCornerRadius: CGFloat = 2.5 {
        didSet {
            indicators.forEach {
                $0?.layer.cornerRadius = indicatorCornerRadius
                $0?.layer.masksToBounds = true
            }
        }
    }
    
    private lazy var indicatorContainer: UIStackView = {
        let view = UIStackView.init(frame: .zero)
        view.spacing = self.indicatorSpacing
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var indicators: [ORSBannerViewIndicator?] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// ORSBannerViewIndicatorPanel组件内部 private方法实现extension定义
private extension ORSBannerViewIndicatorPanel {
    
    // 配置UI控件布局
    private func configUI() {
        addSubview(indicatorContainer)
        indicatorContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateIndicators(count: Int) {
        indicatorContainer.subviews.forEach { $0.removeFromSuperview() }
        indicators.removeAll()
        
        let countTest = count
        guard countTest > 0 else {
            return
        }
        
        for _ in 0..<count {
            let indicator = ORSBannerViewIndicator.init(frame: .init(x: 0, y: 0, width: indicatorSize.width, height: indicatorSize.height))
            indicator.layer.cornerRadius = indicatorCornerRadius
            indicators.append(indicator)
            indicatorContainer.addArrangedSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.size.equalTo(self.indicatorSize)
            }
        }
        updateSelectedIndicator(index: 0)
    }
    
    func updateSelectedIndicator(index: Int) {
        guard index >= 0,
        index <= (indicators.count - 1) else {
            return
        }
        
        indicators.forEach { $0?.backgroundColor = normalColor }
        if let target =  indicators[index] {
            target.backgroundColor = selectedColor
        }
    }
}


class ORSBannerViewIndicator: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
