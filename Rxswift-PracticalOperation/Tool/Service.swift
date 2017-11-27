//
//  Service.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/21.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
class ValidationService {
    //MARK:单例类
    static let instance = ValidationService()
    
    let minCharactersCount = 6
    
    let filePath = NSHomeDirectory() + "/Documents/users.plist"
    
    private init() {}
    //MARK:注册用户名写入本地
    func checkHasUserName(_ userName:String) -> Bool {
        guard let userDict = NSDictionary(contentsOfFile: filePath) else {
            return false
        }
        let usernameArray = userDict.allKeys as NSArray
        return usernameArray.contains(userName)
    }
}
//MARK:注册
extension ValidationService {
    //MARK:用户名判断
    func validationUserName(_ name:String) -> Observable<Result> {
        if name.characters.count == 0 {
            return Observable.just(Result.empty)
        }
        if name.characters.count < minCharactersCount {
            return Observable.just(Result.failed(message: "用户名长度至少为6位"))
        }
        if checkHasUserName(name) {
            return Observable.just(Result.failed(message: "用户名已存在"))
        }
        return Observable.just(Result.ok(message: "用户名可用"))
    }
    //MARK:密码判断
    func validationPassword(_ password : String) -> Result {
        if password.characters.count == 0 {
            return Result.empty
        }
        if password.characters.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        return .ok(message: "密码可用")
    }
    //MARK:确认密码判断
    func validationRePassword(_ password:String, _ rePassword: String) -> Result {
        if rePassword.characters.count == 0 {
            return .empty
        }
        if rePassword.characters.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        if rePassword == password {
            return .ok(message: "密码可用")
        }
        return .failed(message: "两次密码不一样")
    }
    //MARK:注册判断
    func register(_ username : String , _ password : String) -> Observable<Result> {
        let userDict = [username:password]
        if (userDict as NSDictionary).write(toFile: filePath, atomically: true) {
            return Observable.just(Result.ok(message: "注册成功"))
        } else {
            return Observable.just(Result.failed(message: "注册失败"))
        }
    }
}
//MARK:登录
extension ValidationService {
    //MARK:登录用户名判断
    func loginUserNameValid(_ userName:String) -> Observable<Result> {
        if userName.characters.count == 0 {
            return Observable.just(Result.empty)
        }
        if checkHasUserName(userName) {
            return Observable.just(Result.ok(message: "用户名可用"))
        }
        return Observable.just(Result.failed(message: "用户名不存在"))
    }
    // MARK:登录
    func login(_ username:String, password:String) -> Observable<Result> {
        guard let userDict = NSDictionary(contentsOfFile: filePath),
            let userPass = userDict.object(forKey: username)
            else {
                return Observable.just(Result.empty)
        }
        if (userPass as! String) == password {
            return Observable.just(Result.ok(message: "登录成功"))
        }else{
            return Observable.just(Result.failed(message: "密码错误"))
        }
    }
    
    func password(_ username:String, password:String) -> Observable<Bool> {
        guard let userDict = NSDictionary(contentsOfFile: filePath),
            let userPass = userDict.object(forKey: username)
            else {
                return Observable.just(false)
        }
        if (userPass as! String) == password {
            return Observable.just(true)
        }else{
            return Observable.just(false)
        }
    }
}
//MARK:列表数据
class SearchService {
    
    static let instance = SearchService();
    private init(){}
    
    // 获取联系人
    func getContacts() -> Observable<[Contact]> {
        let contactPath = Bundle.main.path(forResource: "Contact", ofType: "plist")
        let contactArr = NSArray(contentsOfFile: contactPath!) as! Array<[String:String]>
        
        var contacts = [Contact]()
        for contactDict in contactArr {
            let contact = Contact(name:contactDict["name"]!, phone: contactDict["phone"]!)
            contacts.append(contact)
        }
        
        return Observable.just(contacts).observeOn(MainScheduler.instance)
    }
    
    func getContacts(withName name: String) -> Observable<[Contact]> {
        if name == "" {
            return getContacts()
        }
        
        let contactPath = Bundle.main.path(forResource: "Contact", ofType: "plist")
        let contactArr = NSArray(contentsOfFile: contactPath!) as! Array<[String:String]>
        
        var contacts = [Contact]()
        for contactDict in contactArr {
            if contactDict["name"]!.contains(name) {
                let contact = Contact(name:contactDict["name"]!, phone: contactDict["phone"]!)
                contacts.append(contact)
            }
        }
        
        return Observable.just(contacts).observeOn(MainScheduler.instance)
    }
}
