//
//  DemoEntity.swift
//  BottomInputView
//
//  Created by hither on 2023/4/21.
//

import Foundation
import UIKit

struct DemoSection {
    let title: String
    let demos: [Demo]
}

struct Demo {
    let title: String
    let des: String
    let vc: UIViewController.Type
}
