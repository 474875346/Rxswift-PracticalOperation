//
//  LoginViewController.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/22.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class LoginViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    func setupRx() -> Void {
        /*
         1.我们给viewModel传入相应的Driver序列。
         2.将viewModel中的对象进行相应的监听，如果是Driver序列，我们这里不使用bingTo，而是使用的Driver，用法和bingTo一模一样。
        3. Deriver的监听一定发生在主线程，所以很适合我们更新UI的操作。
         登录成功会跳转到我们的列表界面。
         */
        let viewmodel = LoginViewModel(input: (userNameTextField.rx.text.orEmpty.asDriver(),pwdTextField.rx.text.orEmpty.asDriver(),loginButton.rx.tap.asDriver()), service: ValidationService.instance)
        
        viewmodel.usernameUseable.drive(nameLabel.rx.validationResult).disposed(by: disposeBag)
        viewmodel.loginButtonEnabled.drive(onNext: { [weak self] (valid) in
            self?.loginButton.isEnabled = valid
            self?.loginButton.backgroundColor = valid ? UIColor.orange:UIColor.gray
            self?.loginButton.setTitleColor(UIColor.white, for: UIControlState(rawValue: 0))
        }).disposed(by: disposeBag)
        viewmodel.loginResult.drive(onNext: { [weak self](result) in
            switch result {
            case let .ok(message):
//                self?.performSegue(withIdentifier: "ListViewController", sender: nil)
                self?.showAlert(message: message)
            case .empty:
                self?.showAlert(message: "")
            case let .failed(message):
                self?.showAlert(message: message)
            }
        }).disposed(by: disposeBag)
    }
    func showAlert(message:String) {
        let action = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
            self?.userNameTextField.text = ""
            self?.pwdTextField.text = ""
            
            // 这个方法是基于点击确定让所有元素还原才抽出的，可不搭理。
            self?.setupRx()
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
