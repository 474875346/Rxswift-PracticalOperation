//
//  RegisterViewController.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/21.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class RegisterViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdLabel: UILabel!
    @IBOutlet weak var rePwdTextField: UITextField!
    @IBOutlet weak var rePwdLabel: UILabel!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }

    
}
extension RegisterViewController {
    func setupRx() -> Void {
        let viewModel = RegisterViewModel()
        /*
         1.其中userNameTextField.rx.text.orEmpty是RxCocoa库中的东西，它把TextFiled的text变成了一个Observable，后面的orEmpty我们可以Command点进去看下，它会把String?过滤nil帮我们变为String类型。
         2.bind(to:viewModel.username)的意思是viewModel.username作为一个observer(观察者)观察userNameTextField上的内容变化。
         3.因为我们有监听，就要有监听资源的回收，所以我们创建一个disposeBag来盛放我们这些监听的资源。
         */
        userNameTextField.rx.text.orEmpty.bind(to: viewModel.username).disposed(by: disposeBag)
        
        viewModel.usernameUseable.bind(to: nameLabel.rx.validationResult).disposed(by: disposeBag)
        
        pwdTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        viewModel.passwordUseable.bind(to: pwdLabel.rx.validationResult).disposed(by: disposeBag)
        
        rePwdTextField.rx.text.orEmpty.bind(to: viewModel.repassword).disposed(by: disposeBag)
        
        viewModel.repasswordUseable.bind(to: rePwdLabel.rx.validationResult).disposed(by: disposeBag)
        
        registButton.rx.tap.bind(to: viewModel.registerTaps).disposed(by: disposeBag)
        
        viewModel.registerButtonEnabled.subscribe(onNext: {[weak self] (valid) in
            self?.registButton.isEnabled = valid
            self?.registButton.backgroundColor = valid ? UIColor.orange:UIColor.gray
            self?.registButton.setTitleColor(UIColor.white, for: UIControlState(rawValue: 0))
        }).disposed(by: disposeBag)
        
        viewModel.registerResult.subscribe(onNext: { [weak self](result) in
            switch result {
            case let .ok(message):
                self?.showAlert(message:message)
            case .empty:
                self?.showAlert(message:"")
            case let .failed(message):
                self?.showAlert(message:message)
            }
        }).disposed(by: disposeBag)
        
    }
    func showAlert(message:String) {
        let action = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
            self?.userNameTextField.text = ""
            self?.pwdTextField.text = ""
            self?.rePwdTextField.text = ""
            
            // 这个方法是基于点击确定让所有元素还原才抽出的，可不搭理。
            self?.setupRx()
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
