//
//  HSHostingController.swift
//  BottomInputView
//
//  Created by hither on 2023/4/21.
//

import Foundation
import SwiftUI

#if os(iOS) || os(tvOS)
    import UIKit
    public typealias ViewController = UIViewController
    public typealias HostingController = UIHostingController
#elseif os(OSX)
    import AppKit
    public typealias ViewController = NSViewController
    public typealias HostingController = NSHostingController
#endif

public class HSHostWrapper: ObservableObject {
    public weak var controller: ViewController?
}

/// allows root view (and children) to access the hosting controller by adding
/// @EnvironmentObject var host:HSHostWrapper
/// then e.g. host.controller?.dismiss()
public class HSHostingController<Content>: HostingController<ModifiedContent<Content, SwiftUI._EnvironmentKeyWritingModifier<HSHostWrapper?>>> where Content: View {

    public init(rootView: Content) {
        let container = HSHostWrapper()
        // swiftlint: disable force_cast
        let modified = rootView.environmentObject(container) as! ModifiedContent<Content, _EnvironmentKeyWritingModifier<HSHostWrapper?>>
        super.init(rootView: modified)
        container.controller = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.setNeedsUpdateConstraints()
    }
}

#if os(iOS) || os(tvOS)
public extension HSHostingController {
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        
        if ignoreSafeArea {
            disableSafeArea()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else {
            return
        }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else {
                return
            }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else {
                return
            }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            if let method2 = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
                let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
                class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"), imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method2))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
#endif
