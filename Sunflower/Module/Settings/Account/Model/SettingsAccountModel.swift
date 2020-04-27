//
//  SettingsAccountModel.swift
//  Sunflower
//
//  Created by Lee on 2020/4/27.
//

import Foundation

class SettingsAccountModel {
    
    var datas: [Item] { items }
    var changed: (([Item]) -> Void)?
    
    private var items: [Item] = [] {
        didSet { changed?(items) }
    }
    private var observations: [UserDefaultsObservation] = []
    
    init() {
        setup()
        setupObservation()
    }
    
    /// 设置数据
    private func setup() {
        do {
            let models: [Account.Pgyer] = UserDefaults.AccountInfo.model(forKey: .pgyer) ?? []
            handle(.pgyer, with: models.map { .init(name: $0.alias, key: $0.key) })
        }
        do {
            let models: [Account.Firim] = UserDefaults.AccountInfo.model(forKey: .firim) ?? []
            handle(.firim, with: models.map { .init(name: $0.alias, key: $0.key) })
        }
    }
    
    /// 设置监听
    private func setupObservation() {
        do {
            let observation = UserDefaults.AccountInfo.observe(forKey: .pgyer) {
                [weak self] (old: [Account.Pgyer]?, new: [Account.Pgyer]?) in
                self?.handle(.pgyer, with: new?.map { .init(name: $0.alias, key: $0.key) } ?? [])
            }
            observations.append(observation)
        }
        do {
            let observation = UserDefaults.AccountInfo.observe(forKey: .firim) {
                [weak self] (old: [Account.Firim]?, new: [Account.Firim]?) in
                self?.handle(.firim, with: new?.map { .init(name: $0.alias, key: $0.key) } ?? [])
            }
            observations.append(observation)
        }
    }
    
    private func handle(_ type: Account, with childs: [Item.Child]) {
        guard self.childs(type: type) != childs  else {
            return
        }
        update(type: type, with: childs)
    }
}

extension SettingsAccountModel {
    
    /// 移除数据
    /// - Parameters:
    ///   - type: 类型
    ///   - child: 子项
    func remove(type: Account, with child: Item.Child) {
        switch type {
        case .pgyer:
            var models: [Account.Pgyer] = UserDefaults.AccountInfo.model(forKey: .pgyer) ?? []
            models.removeAll { $0.key == child.key }
            UserDefaults.AccountInfo.set(model: models, forKey: .pgyer)
            
        case .firim:
            var models: [Account.Firim] = UserDefaults.AccountInfo.model(forKey: .firim) ?? []
            models.removeAll { $0.key == child.key }
            UserDefaults.AccountInfo.set(model: models, forKey: .firim)
        }
    }
}

extension SettingsAccountModel {
    
    private func childs(type: Account) -> [Item.Child] {
        return items.first(where: { $0.type == type })?.childs ?? []
    }
    
    private func update(type: Account, with childs: [Item.Child]) {
        if let index = items.firstIndex(where: { $0.type == type }) {
            if childs.isEmpty {
                items.remove(at: index)
                
            } else {
                var item = items[index]
                item.childs = childs
                items[index] = item
            }
            
        } else {
            items.append(.init(type: type, childs: childs))
        }
    }
}

extension SettingsAccountModel {
    
    struct Item: Equatable {
        let type: Account
        var childs: [Child]
        
        struct Child: Equatable {
            let name: String
            let key: String
        }
    }
}
