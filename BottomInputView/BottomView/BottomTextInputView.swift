//
//  BottomTextInputView.swift
//  BottomInputView
//
//  Created by nice2meet on 2023/2/27.
//

import UIKit
import SnapKit

// MARK: - 位于屏幕底部、用于输入评论,发送等操作面板视图组件
public enum BottomTextInputViewActionType {
    /// 评论文字编辑改变
    case textChanged(text: String?)
    /// 转发选中
    case resendClicked(isSelected: Bool)
    /// 井号点击
    case hashClicked
    /// At 点击
    case atClicked
    /// 发送按钮点击
    case sendClick
}

protocol BottomTextInputViewDelegate: NSObject {
    /// 当视图展示/键盘收起时回调, keyboardwillShow = true,keyboardwillHide = false
    /// 键盘隐藏时，可使用snp.updateConstraint 方法 重新还原控件布局，需避免使用固定高度，控件内部已经算好高度
    /// 参考//  ViewController.swift
    func inputViewKeyboardOn(show: Bool)->Void
    /// 可用于事件传递
    func inputViewOnHandle(action: BottomTextInputViewActionType)

}

/// 位于屏幕底部、用于输入评论,发送等操作面板视图组件
public class BottomTextInputView: UIView {
    
    /// 代理
    private weak var delegate: BottomTextInputViewDelegate?
    
    /// 发送按钮是否可用
    var sendBtnEnabled: Bool = false{
        didSet{
            
        }
    }
    
    // 允许输入最大字符数字
    private let maxInputCount: Int = 100
    
    /// 当前键盘是否展开状态
    private var isKeyboardOn: Bool = false{
        didSet{
            let h: CGFloat = isKeyboardOn ? defaultToolBarHeight : 0
            bottomActionContainerHeightCons?.constraint.update(offset: h)
            bottomContainer.isHidden = !isKeyboardOn
        }
    }
    
    // 输入控件背景
    private let bgView: UIView = {
        let aView = UIView()
        aView.backgroundColor = UIColor.init(white: 0, alpha: 0.55)
        aView.alpha = 0.0
        
        return aView
    }()
    
    private let bottomContainer = UIView()
    
    ///  是否转发按钮选中
    private var isResendSelected: Bool = false{
        didSet{
            let checkedImg = isResendSelected ? "icon-selected" : "icon-unselected"
            resendCheckedBtn.setImage(UIImage.init(named: checkedImg), for: .normal)
        }
    }
    
    /// 输入框高度更新约束
    private var textViewHeightCons: ConstraintMakerEditable? = nil
    
    /// 底部交互按钮高度更新约束
    private var bottomActionContainerHeightCons: ConstraintMakerEditable? = nil
    
    /// 文本框
    private let textView: RSKPlaceholderTextView = {
        let inputTextView = RSKPlaceholderTextView.init()
        inputTextView.textColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00)
        inputTextView.backgroundColor = .clear
        inputTextView.font = UIFont.systemFont(ofSize: 15)
        inputTextView.placeholder = "点击输入评论"
        inputTextView.placeholderColor = UIColor(red:0.36, green:0.36, blue:0.36, alpha:1.00)
        
        return inputTextView
    }()
    
    private let textViewCounterLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = UIColor(red:0.36, green:0.36, blue:0.36, alpha:1.00)
        label.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.85, alpha:1.00)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4.0
        return label
    }()
    
    /// 发送按钮
    private let sendBtn: UIButton = {
        let btn = UIButton.init(frame: .zero)
        btn.setTitle("发送", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red:0.13, green:0.60, blue:0.85, alpha:1.00)
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        
        return btn
    }()
    
    /// 转发状态按钮
    private let resendCheckedBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon-unselected"), for: .normal)
        return btn
    }()
    
    init(delegate: BottomTextInputViewDelegate){
        super.init(frame: .zero)
        self.delegate = delegate
        
        configView()
        config()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.point(inside: point, with: event) && textView.isFirstResponder){
            textView.resignFirstResponder()
        }
        return super.hitTest(point, with: event)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}


private extension BottomTextInputView{
    
    /// 如果键盘展开中，那么底部按钮工具区不展示 高度0,否则展示 高度 66
    var bottomToolBarHeight: CGFloat {
        let toolBarHeight: CGFloat = defaultToolBarHeight
        return isKeyboardOn ? toolBarHeight : 0
    }
    
    /// 底部按钮模块高度
    var defaultToolBarHeight: CGFloat{
        return 66.0
    }
    
    /// UITextView 最小高度
    var inputViewMinLineHeight: CGFloat{
        return 32
    }
    
    var inputViewAndCounterSpace: CGFloat{
        return UIDef.defaultMargin * 0.5
    }
    
    @objc func bgViewOnTap(sender: UITapGestureRecognizer){
        textView.resignFirstResponder()
    }
    
    @objc func eventForwardForbidden(){ }
    
    func bgView(show: Bool){
        if (show){
            superview?.insertSubview(bgView, belowSubview: self)
            bgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.25, delay: 0.25, options: UIView.AnimationOptions.curveEaseInOut) {
                self.bgView.alpha = 1
            } completion: { _ in
            }
            return
        }
        
        bgView.removeFromSuperview()
        bgView.alpha = 0
    }
    
    func config(){
        
        registerKeyboardNotifications()
        
        textView.delegate = self
        textViewDidChange(textView)
        resendCheckedBtn.addTarget(self, action: #selector(resendClicked), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendClicked), for: .touchUpInside)
        
        let bgGes = UITapGestureRecognizer.init(target: self, action: #selector(bgViewOnTap(sender:)))
         bgView.addGestureRecognizer(bgGes)
        
        let eventForwardForbiddenGes = UITapGestureRecognizer.init(target: self, action: #selector(eventForwardForbidden))
        addGestureRecognizer(eventForwardForbiddenGes)
        
    }
    
    func configView(){
        backgroundColor = .white
        //
        let topContainer = UIView()
        topContainer.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.85, alpha:1.00)
        topContainer.layer.cornerRadius = 0.5 * UIDef.defaultMargin
        topContainer.clipsToBounds = true
        addSubview(topContainer)
        
        //
        addSubview(bottomContainer)
        topContainer.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(UIDef.defaultMargin)
            make.bottom.equalTo(bottomContainer.snp.top)
        }
        bottomContainer.clipsToBounds = true
        bottomContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            // let offSet = isKeyboardOn ? 0.0 : UIDef.safeAreaBottom
            let inset: CGFloat = 0
            make.bottom.equalToSuperview().inset(inset)
            self.bottomActionContainerHeightCons = make.height.equalTo(self.bottomToolBarHeight)
        }
        
        // 上边输入框区域子视图
        let textViewWrapper = UIView()
        textViewWrapper.backgroundColor = .clear
        topContainer.addSubview(textViewWrapper)
        textViewWrapper.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset((UIDef.defaultMargin * 1.5))
            make.bottom.equalToSuperview()
        }
        textViewWrapper.addSubview(textView)
        textViewWrapper.addSubview(textViewCounterLabel)
        
        textView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(textViewCounterLabel.snp.top).offset(-inputViewAndCounterSpace)
            self.textViewHeightCons = make.height.equalTo(self.inputViewMinLineHeight)
        }
        textView.delegate = self
        textViewCounterLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(UIDef.defaultMargin * 0.5)
            make.bottom.equalToSuperview().inset(UIDef.defaultMargin * 0.5)
            make.height.greaterThanOrEqualTo(UIDef.defaultMargin)
        }
        
        // 下边区域
        let leftStack = UIStackView.init()
        leftStack.axis = .horizontal
        leftStack.spacing = UIDef.defaultMargin
        bottomContainer.addSubview(leftStack)
        leftStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset((UIDef.defaultMargin * 1.5))
            make.centerY.equalToSuperview()
        }
        leftStack.addArrangedSubview(resendCheckedBtn)
        let resendLabel: UILabel = .init(frame: .zero)
        resendLabel.text = "同时转发到动态"
        resendLabel.isUserInteractionEnabled = true
        let resendLabelGes = UITapGestureRecognizer.init(target: self, action: #selector(resendClicked))
        resendLabel.addGestureRecognizer(resendLabelGes)
        
        resendLabel.textColor = UIColor(red:0.29, green:0.28, blue:0.27, alpha:1.00)
        resendLabel.font = .systemFont(ofSize: 14)
        resendLabel.sizeToFit()
        leftStack.addArrangedSubview(resendLabel)
        
        let rightStack = UIStackView.init()
        rightStack.axis = .horizontal
        rightStack.alignment = .fill
        rightStack.spacing = UIDef.defaultMargin
        bottomContainer.addSubview(rightStack)
        rightStack.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(UIDef.defaultMargin * 1.5)
            make.centerY.equalToSuperview()
        }
        
        let hashBtn = UIButton.init(frame: .zero)
        hashBtn.setImage(UIImage.init(named: "icon-hash"), for: .normal)
        hashBtn.addTarget(self, action: #selector(hashClicked), for: .touchUpInside)
        let atBtn = UIButton.init(frame: .zero)
        atBtn.setImage(UIImage.init(named: "icon-at"), for: .normal)
        atBtn.addTarget(self, action: #selector(atClicked), for: .touchUpInside)
        rightStack.addArrangedSubview(hashBtn)
        rightStack.addArrangedSubview(atBtn)
        rightStack.addArrangedSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 96, height: 36))
        }
        
    }
}

extension BottomTextInputView: UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        if maxInputCount > 0, let currentText: String = textView.text {
            let currentCount: Int = currentText.count
            if currentCount > maxInputCount {
                textView.text = currentText.padding(toLength: maxInputCount, withPad: "", startingAt: 0)
            }
        }
        let currentCount: Int = textView.text?.count ?? 0
        textViewCounterLabel.text = "\(currentCount)/\(maxInputCount)"
        
        //
        textDidChange(textView: textView)
        
        // 最大支持输入行数默认3行
        let maxCountOfLine: CGFloat = 3;
        let cH: CGFloat = textView.contentSize.height
        
        var lineH:CGFloat = UIFont.systemFont(ofSize: 15).lineHeight
        if let font = textView.font {
            lineH = font.lineHeight
        }
        let maxShowH = lineH * maxCountOfLine
        
        let targetH: CGFloat = max(min(cH, maxShowH),inputViewMinLineHeight)
        self.textViewHeightCons?.constraint.update(offset: targetH)
    }
}

private extension BottomTextInputView{
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let animationCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        else { return }
        
        if self.textView.isFirstResponder,
           let window = self.window{
            
            isKeyboardOn = true
            if let aDelegate = self.delegate{
                aDelegate.inputViewKeyboardOn(show: true)
            }
            
            let keyBoardFrame = window.convert(keyboardFrameValue.cgRectValue,from:nil)
            let targetBottomOffset = keyBoardFrame.height
            
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve) ) {
                self.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().inset(targetBottomOffset)
                }
                self.superview?.layoutIfNeeded()
            } completion: { finished in }
            
            bgView(show: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardOn = false
        bgView(show: false)
        
        guard let delegate = delegate else { return }
        delegate.inputViewKeyboardOn(show: false)
    }
}

private extension BottomTextInputView{
    
    @objc func hashClicked(){
        guard let delegate = delegate else { return }
        delegate.inputViewOnHandle(action: .hashClicked)
    }
    
    @objc func atClicked(){
        guard let delegate = delegate else { return }
        delegate.inputViewOnHandle(action: .atClicked)
    }
    
    @objc func resendClicked(){
        isResendSelected = !isResendSelected
        guard let delegate = delegate else { return }
        delegate.inputViewOnHandle(action: .resendClicked(isSelected: isResendSelected))
    }
    
    @objc func sendClicked(){
        guard let delegate = delegate else { return }
        delegate.inputViewOnHandle(action: .sendClick)
    }
    
    @objc func textDidChange(textView: UITextView?){
        guard let delegate = delegate else { return }
        delegate.inputViewOnHandle(action: .textChanged(text: textView?.text))
    }
}

