//
//  ORSBannerDemoController.swift
//  BottomInputView
//
//  Created by hither on 2023/4/21.
//

import UIKit

class ORSBannerDemoController: UIViewController {
    
    var banner: ORSBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        banner = ORSBannerView.init(frame: .init(x: 0, y: 88, width: view.frame.width, height: 300), delegate: self)
        view.addSubview(banner!)
        banner?.register(cell: ORSBannerViewCell.self)
        banner?.autoScrollEnabled = true
        banner?.indicatorPanel.normalColor = .systemPink
        banner?.indicatorPanel.selectedColor = .white
        banner?.reloadData()
    }
}

extension ORSBannerDemoController: ORSBannerViewDelegate {
    
    func orsBannerView(didScrollTo index: Int) {}
    
    func orsBannerView(didSelect index: Int) {}
    
    func orsBannerView(scrollTo index: Int) {}
    
    func orsBannerViewNumberOfItems() -> Int {
        return 5
    }
    
    func orsBannerView(collectionView: UICollectionView, cellForItem indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ORSBannerViewCell.self)", for: indexPath) as! ORSBannerViewCell
        return cell
    }
    
}
