//
//  BannerController.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/3/22.
//

import UIKit

class BannerController: UIViewController {

    var bannersCount: Int = 5
    
    lazy var banner: BannerView = {
        let banner = BannerView.init(frame: .zero, viewsBuilder: buildViews(parent:))
        return banner
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(300)
        }
        
        banner.count = bannersCount
    }
    

    func buildViews(parent: UIView) -> [UIView] {
        var views = [UIView]()
        for i in 0..<self.bannersCount {
            let view: UIView = .init(frame: .zero)
            let random =  CGFloat(arc4random() % 9999) / 10000.0
            print(random)
            view.backgroundColor = .init(white: random, alpha: random)
            views.append(view)
        }
        return views
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
