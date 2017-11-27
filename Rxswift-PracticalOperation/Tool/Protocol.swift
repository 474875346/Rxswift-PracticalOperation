//
//  Protocol.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/21.
//  Copyright © 2017年 新龙科技. All rights reserved.
//
import UIKit
import Foundation
import RxCocoa
import RxSwift
enum Result {
    case ok(message:String)
    case empty
    case failed(message:String)
}
extension Result {
    var textColor:UIColor {
        switch self {
        case .ok :
            return UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
        case .empty :
            return UIColor.black
        case .failed :
            return UIColor.red
        }
    }
}
/*
 1.首先，我们对Result进行了扩展，添加了isValid属性，如果状态是ok，这个属性就为true，否则为false
 2.然后对Result添加了一个textColor属性，如果状态为ok则为绿色，否则使用红色
 3.我们对UILabel进行了UIBingObserver，根据result结果，进行它的text和textColor显示
 4.我们对UITextField进行了UIBingObserver，根据result结果，对它的isEnabled进行设置。
 */
extension Result {
    var isValid:Bool {
        switch self {
        case .ok :
            return true
        default:
            return false
        }
    }
}

extension Result {
    var description : String {
        switch self {
        case let .ok(message) :
            return message
        case .empty :
            return ""
        case let .failed(message) :
            return message
        }
    }
}
extension Reactive where Base:UILabel {
    var validationResult:Binder<Result> {
        return Binder(base){
            label,result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
extension Reactive where Base:UITextField {
    var inputEnabled:Binder<Result> {
        return Binder(base) {
            textfield,result in
            textfield.isEnabled = result.isValid
        }
    }
}


