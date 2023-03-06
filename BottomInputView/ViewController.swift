//
//  ViewController.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/2/27.
//

import UIKit

class ViewController: UIViewController {
    
    var testView: BottomTextInputView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        testView = BottomTextInputView.init(delegate: self)
        view.addSubview(testView!)
        testView?.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(60)
        }        
    }
    
}



extension ViewController: BottomTextInputViewDelegate{
    func inputViewKeyboardOn(show: Bool) {
        
        if (!show){
            UIView.animate(withDuration: 0.25) {
                self.testView?.snp.updateConstraints({ make in
                    make.bottom.equalToSuperview().inset(60)
                    self.view.layoutIfNeeded()
                })
            } completion: { finished in
                print(finished)
            }
        }
    }
    
    // 处理面板点击等事件
    func inputViewOnHandle(action: BottomTextInputViewActionType) {
        print(action)
    }
}
