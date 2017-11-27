//
//  ListViewModel.swift
//  Rxswift-PracticalOperation
//
//  Created by 新龙科技 on 2017/11/22.
//  Copyright © 2017年 新龙科技. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class ListViewModel {
    var models : Driver<[Contact]>
    init(with searchText:Observable<String>,service:SearchService) {
        models = searchText.debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .flatMap{
                text in
                service.getContacts(withName: text)
            }.asDriver(onErrorJustReturn: [])
    }
}
