//
//  LoginViewModel.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/22.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class LoginViewModel {
    let usernameUseable : Driver<Result>
    let loginButtonEnabled : Driver<Bool>
    let loginResult : Driver<Result>
    init(input:(username:Driver<String>,password:Driver<String>,loginTaps:Driver<Void>),service:ValidationService) {
        usernameUseable = input.username.flatMapLatest({ (username)  in
            return service.loginUserNameValid(username).asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        })
        let usernameAndPass = Driver.combineLatest(input.username, input.password) {
            return ($0,$1)
        }
        loginResult = input.loginTaps.withLatestFrom(usernameAndPass).flatMapLatest{
            (username,password) in
            service.login(username, password: password).asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        loginButtonEnabled = input.password.withLatestFrom(usernameAndPass).flatMapLatest{
            (username,password) in
            service.password(username, password: password).asDriver(onErrorJustReturn: false)
        }
    }
    
}
