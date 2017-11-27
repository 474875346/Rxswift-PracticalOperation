//
//  RegisterViewModel.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/21.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class RegisterViewModel {
    let username = Variable<String>("")
    let password = Variable<String>("")
    let repassword = Variable<String>("")
    
    
    let usernameUseable : Observable<Result>
    let passwordUseable : Observable<Result>
    let repasswordUseable : Observable<Result>
    /*
     1.registerTaps我们使用了PublishSubject，因为不需要有初始元素，其实前面的Variable都可以换成PublishSubject。大伙可以试试;
     2.registerButtonEnabled就是注册按钮是否可用的输出，这个其实关系到username和password；
     3. registerResult就只最后注册结果了.
     */
    let registerButtonEnabled : Observable<Bool>
    let registerResult : Observable<Result>
    let registerTaps = PublishSubject<Void>()
    
    
    init() {
        let server = ValidationService.instance
        /*
         viewModel中，我们把username当做observable(被观察者)，然后对里面的元素进行处理之后发射对应的事件。
         */
        usernameUseable = username.asObservable().flatMapLatest({
            username in
            return server.validationUserName(username).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "username检查出错")).share(replay: 1)
        })
        
        passwordUseable = password.asObservable().map({
            password in
            return server.validationPassword(password)
        }).share(replay: 1)
        
        repasswordUseable = Observable.combineLatest(password.asObservable(), repassword.asObservable(), resultSelector: {
            return server.validationRePassword($0, $1)
        }).share(replay: 1)
        /*
         1.registerButtonEnabled的处理，把username、password和rePassword的处理结果绑定到一起，返回一个总的结果流，这是个Bool值的流。
         2.我们先将username和password组合，得到一个元素是它俩组合的元祖的流。
         3.然后对registerTaps事件进行监听，我们拿到每一个元组进行注册行为，涉及到耗时数据库操作，我们需要对这个过程进行监听，所以我们使用flatMap函数，返回一个新的流。
         */
        registerButtonEnabled = Observable.combineLatest(usernameUseable, passwordUseable, repasswordUseable, resultSelector: { (username, password, repassword) in
            return username.isValid && password.isValid && repassword.isValid
        }).distinctUntilChanged().share(replay: 1)
        
        let usernameAndPwd = Observable.combineLatest(username.asObservable(), password.asObservable(), resultSelector: {
            return ($0,$1)
        })
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPwd).flatMapLatest{
            return server.register($0, $1).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "注册失败"))
            }.share(replay: 1)
    }
}
