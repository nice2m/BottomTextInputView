//
//  ORSBannerView.swift
//  BannerViewDemo
//
//  Created by hither on 2023/3/22.
//

import UIKit
import SnapKit

protocol ORSBannerViewDelegate: AnyObject {
    func orsBannerView(didScrollTo index: Int)
    func orsBannerView(didSelect index: Int)
    
    func orsBannerViewNumberOfItems() -> Int
    func orsBannerView(collectionView: UICollectionView, cellForItem indexPath: IndexPath) -> UICollectionViewCell
}

/*
banner 页面指示器位置共3 种情况，布局时注意⚠️
 
 case none && case inBanner(space: CGFloat)
页面指示器与 banner 底边对齐 && 页面指示器居于banner 之中
即collectionView.layout.itemSize.height = ORSBannerView().bounds.size.height

 case bellowBanner(space: CGFloat)
页面指示器在 banner 垂直居下方
即collectionView.layout.itemSize.height = ORSBannerView().bounds.size.height - space - indicatorPanel.indicatorSize.height
*/

enum ORSBannerViewIndicatorPositionType {
    case none
    case inBanner(space: CGFloat)
    case bellowBanner(space: CGFloat)
}

class ORSBannerView: UIView {
      
    var selectedIndex: Int = 0 {
        didSet {
            currentIndex = selectedIndex
        }
    }
    
    private var currentIndex: Int = 0 {
        didSet {
            updateScroll2(index: currentIndex)
            updateIndicator2(index: currentIndex)
        }
    }
    
    /// 如果开启了restoreSelectedIndexBeforeReuseEnabled = true时，那么刷新数据后，页面指示器会恢复选中数据刷新前选中的Index
    var restoreSelectedIndexBeforeReuseEnabled = true
    
    /// 如果banner 数 小于 hidePageIndicatorsWhenLessThanCount，那么隐藏页面指示器，默认2
    var hidePageIndicatorsWhenLessThanCount = 2

    private var selectedIndexBeforeReuse: Int = 0

    var autoScrollEnabled = false {
        didSet {
            invalidateAutoScrollTimer()
            
            if autoScrollEnabled {
                setUpAutoScrollTimer()
            }
        }
    }
    
    var autoScrollInterval: TimeInterval = 5
    
    var indicatorPositionType: ORSBannerViewIndicatorPositionType = .none {
        didSet {
            adjustConstraints()
        }
    }
      
    private var autoScrollTimer: Timer?
    
    private weak var delegate: ORSBannerViewDelegate?
    
    private(set) lazy var indicatorPanel: ORSBannerViewIndicatorPanel = {
        let view = ORSBannerViewIndicatorPanel.init(frame: .zero)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    private lazy var indicatorContainer: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    init(frame: CGRect, delegate: ORSBannerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        configUI()
        configAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func register(cell type: UICollectionViewCell.Type) {
        collectionView.register(type, forCellWithReuseIdentifier: "\(type)")
    }
    
    override  func layoutSubviews() {
        super.layoutSubviews()
        adjustCollectionViewItemSize()
    }
    
    func reloadData() {
        collectionView.reloadData()
                
        DispatchQueue.main.async {
            let dataCount = self.delegate?.orsBannerViewNumberOfItems() ?? 0
            
            // 刷新自动滚动 timer 配置
            if self.autoScrollEnabled {
                if  dataCount <= 1 {
                    self.invalidateAutoScrollTimer()
                } else {
                    self.setUpAutoScrollTimer()
                }
            }
            
            var targetIndex = 0
            
            if self.restoreSelectedIndexBeforeReuseEnabled {
                // 如果开启了restoreSelectedIndexBeforeReuseEnabled = true时，那么刷新数据后，页面指示器会恢复选中数据刷新前选中的Index
                if self.selectedIndexBeforeReuse <= (dataCount - 1) {
                    targetIndex = self.selectedIndexBeforeReuse
                }
            }
            self.indicatorPanel.count = dataCount
            self.currentIndex = targetIndex
            
            self.indicatorPanel.isHidden = dataCount < self.hidePageIndicatorsWhenLessThanCount
        }
    }
    
    deinit {
        invalidateAutoScrollTimer()
    }
}

// ORBannerView组件内部 private方法实现extension定义
private extension ORSBannerView {
    
    private func invalidateAutoScrollTimer() {
        self.autoScrollTimer?.invalidate()
        self.autoScrollTimer = nil
    }
    
    private func setUpAutoScrollTimer() {
        invalidateAutoScrollTimer()
        
        let timer = Timer.init(timeInterval: autoScrollInterval, repeats: true, block: { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            weakSelf.fireAutoScroll()
        })
        autoScrollTimer = timer
        RunLoop.main.add(timer, forMode: .default)
    }
    
    private func updateScroll2(index: Int, animated: Bool = false) {
        let offsetX = CGFloat(index) * bounds.width
        collectionView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: animated)
        
        if !animated {
            delegate?.orsBannerView(didScrollTo: index)
        }
    }
    
    private func updateIndicator2(index: Int) {
        indicatorPanel.selectedIndex = index
    }

    private func adjustCollectionViewItemSize() {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        var heightDelta: CGFloat = 0
        switch indicatorPositionType {
        case .bellowBanner(let space):
            heightDelta = space + indicatorPanel.indicatorSize.height
            
        default:
            heightDelta = 0
        }
        
        let itemHeight: CGFloat = bounds.size.height - heightDelta
        let itemWidth: CGFloat = bounds.size.width
        
        layout.itemSize = .init(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func adjustConstraints() {
        guard indicatorContainer.superview != nil,
              collectionView.superview != nil else {
            return
        }
                
        switch indicatorPositionType {
        case .none:
            indicatorContainer.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            collectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
        case .inBanner(let space):
            indicatorContainer.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(space)
            }
            collectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
        case .bellowBanner(let space):
            let collectionInset: CGFloat = space + indicatorPanel.indicatorSize.height
            
            collectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(collectionInset)
            }
            indicatorContainer.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
    }
    
    private func fireAutoScroll() {
        let itemCount = delegate?.orsBannerViewNumberOfItems() ?? 0
        guard itemCount > 1 else {
            return
        }
        
        /// 避免 以下除法计算除以double类型 0 的错误，导致  ​Fatal error: Double value cannot be converted to Int because it is either infinite or NaN
        /// refed from https://stackoverflow.com/questions/42000061/swift-3fatal-error-double-value-cannot-be-converted-to-int-because-it-is-eithe
        let legalNumberChecked = collectionView.contentOffset.x.isFinite && bounds.width.isFinite
        guard legalNumberChecked else {
            return
        }
        let tempCurrentIndex = floor(collectionView.contentOffset.x / bounds.width)
        guard tempCurrentIndex.isFinite else {
            return
        }
        let currentIndex = Int(tempCurrentIndex)
        var nextIndex = currentIndex + 1
        let maxIndex = itemCount - 1
        if nextIndex > maxIndex {
            nextIndex = 0
        }
        updateScroll2(index: nextIndex, animated: nextIndex != 0)
        updateIndicator2(index: nextIndex)
    }
    
    // 配置UI控件布局
    private func configUI() {
        addSubview(contentView)
        contentView.addSubview(collectionView)
        contentView.addSubview(indicatorContainer)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        indicatorContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        indicatorContainer.addSubview(indicatorPanel)
        indicatorPanel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // 配置各控件具体操作
    private func configAction() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


extension ORSBannerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else {
            return 0
        }
        
        let count = delegate.orsBannerViewNumberOfItems()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate else {
            return .init()
        }
        return delegate.orsBannerView(collectionView: collectionView, cellForItem: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        delegate.orsBannerView(didSelect: indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let delegate = delegate,
              delegate.orsBannerViewNumberOfItems() > 0 else {
            return
        }
        let legalNumberChecked = scrollView.contentOffset.x.isFinite && scrollView.bounds.width.isFinite
        guard legalNumberChecked else {
            return
        }
        let tempCurrentIndex = floor(scrollView.contentOffset.x / scrollView.bounds.width)
        guard tempCurrentIndex.isFinite else {
            return
        }
        let index = Int(tempCurrentIndex)
        updateIndicator2(index: index)
        selectedIndexBeforeReuse = index
        
        delegate.orsBannerView(didScrollTo: index)
    }
}
