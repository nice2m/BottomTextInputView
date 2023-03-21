//
//  BannerView.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/3/22.
//

import SnapKit
import UIKit

typealias BannerViewItemBuilder = (_ parent: UIView) -> [UIView]

class BannerView: UIView {
    
    var bannerInsets: UIEdgeInsets = .zero
    
    var indicatorInsets: UIEdgeInsets = .zero
    
    var selectedIndex: Int = 0
    
    var viewsBuilder: BannerViewItemBuilder?
    
    private(set) var indicatorPanel: IndicatorPanel = {
        let view = IndicatorPanel.init(frame: .zero)
        
        return view
    }()
    
    var count: Int = 3 {
        didSet{
            childViewList = self.viewsBuilder?(self.contentStack) ?? []
            update(views: childViewList)
        }
    }
    
    // var indicatorAlign
    
    private var childViewList = [UIView]()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init(frame: .zero)
        scroll.isPagingEnabled = true
        
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView.init(frame: .zero)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        
        return stack
    }()
    
    private lazy var indicatorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(white: 0.0, alpha: 0.55)
        
        return view
    }()
    
    init(frame: CGRect,viewsBuilder: @escaping BannerViewItemBuilder) {
        super.init(frame: frame)
        self.viewsBuilder = viewsBuilder
        
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        let index: Int = Int(scrollView.contentOffset.x / CGFloat(scrollView.bounds.size.width))
        updateIndicator(selectedIndex: index)
    }
}

extension BannerView {
    private func configView() {
        addSubview(scrollView)
        addSubview(indicatorContainerView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.bannerInsets)
        }
        indicatorContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(indicatorInsets.bottom)
            make.height.equalTo(40)
        }
        indicatorContainerView.addSubview(indicatorPanel)
        updateIndicator(count: 0, selectedIndex: 0)
        
        scrollView.delegate = self
        
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func updateIndicator(count: Int,selectedIndex: Int){
        indicatorPanel.removeFromSuperview()
        
        indicatorPanel = .init(frame: .zero)
        indicatorContainerView.addSubview(indicatorPanel)
        indicatorPanel.count = count
        indicatorPanel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func updateIndicator(selectedIndex: Int){
        indicatorPanel.selectedIndex = selectedIndex
    }
    
    private func update(views: [UIView]) {
        contentStack.subviews.forEach{ $0.removeFromSuperview() }
        let width: CGFloat = (superview?.bounds.width ?? 0) * CGFloat(views.count)
        
        contentStack.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(width)
        }
        views.forEach { aView in
            contentStack.addArrangedSubview(aView)
        }
        
        updateIndicator(count: views.count, selectedIndex: 0)
    }
}
