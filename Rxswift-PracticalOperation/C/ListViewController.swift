//
//  ListViewController.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/22.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class ListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let disposeBag = DisposeBag()
    
    var searchBarText:Observable<String>  {
        return searchBar.rx.text.orEmpty.throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewmodel = ListViewModel(with: searchBarText, service: SearchService.instance)
        viewmodel.models.drive(tableview.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){(row, element, cell) in
            cell.textLabel?.text = element.name
            cell.detailTextLabel?.text = element.phone
            }.disposed(by: disposeBag)
        tableview.rx.modelSelected(Contact.self).subscribe(onNext: { (model) in
            print(model.name)
        }).disposed(by: disposeBag)
        
    }
}
