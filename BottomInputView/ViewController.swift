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
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
}


extension ViewController: BottomTextInputViewDelegate{
    func inputViewKeyboardOn(show: Bool) {
        print("inputViewKeyboardOn:\(show)")
    }
    
    // 处理面板点击等事件
    func inputViewOnHandle(action: BottomTextInputViewActionType) {
        print(action)
    }
}
