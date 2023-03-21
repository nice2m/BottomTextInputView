//
//  IndicatorView.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/3/22.
//

import UIKit

class IndicatorPanel: UIView {
    
    var count: Int = 3
    
    var itemSize: CGSize = .init(width: 20, height: 5)
    
    var spacing: CGFloat = 8
    
    var normalColor: UIColor = UIColor.init(white: 0, alpha: 0.55)
    
    var selectedColor: UIColor = UIColor.white
    
    var selectedIndex: Int = 0 {
        didSet {
            if subviews[selectedIndex] != nil {
                return
            }
            subviews.forEach{$0.backgroundColor = normalColor}
            subviews[selectedIndex].backgroundColor = selectedColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension IndicatorPanel {
    
    private func configView() {
        for i in 0..<count {
            let originY: CGFloat = 0
            let originX: CGFloat = CGFloat(i) * itemSize.width + CGFloat(i) * spacing
            let view = UIView.init(frame: .init(x: originX, y: originY, width: itemSize.width, height: itemSize.height))
            view.backgroundColor = self.normalColor
            self.addSubview(view)
        }
    }
}

private class IndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        
    }
}
