//
//  UIDefine.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/2/28.
//

import UIKit

public struct UIDef{
    static let screenW = UIScreen.main.bounds.width
    static let screenH = UIScreen.main.bounds.height
    static let defaultMargin: CGFloat = 8.0
    
    static var safeAreaBottom: CGFloat = {
        if #available(iOS 11.0, *) {
            guard let delegate = UIApplication.shared.delegate,
                  let keyWindowTmp = delegate.window,
                  let keyWindow = keyWindowTmp
            else {
                return 0
            }
            
            return keyWindow.safeAreaInsets.bottom
        }
        
        return 0.0
    }()
}
