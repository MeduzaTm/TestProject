//
//  FeedPresenter.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 19.11.2025.
//

import Foundation
import CoreData

protocol FeedPresenterInput {
    func viewDidLoad()
    func refreshRequested()
}

class FeedPresenter: FeedPresenterInput {
    private weak var view: FeedViewInput?
    private let network = NetworkManager.shared
    private let storage = StorageManager.shared
    
    init(view: FeedViewInput) {
        self.view = view
    }
    
    func viewDidLoad() {
        print("FeedPresenter viewDidLoad")
        view?.showLoading()
        storage.fetchInitialPosts { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handle(result, shouldEndRefreshing: false)
            }
        }
    }
    
    func refreshRequested() {
        network.fetchPosts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let dtos):
                self.storage.saveToCoreData(postDto: dtos) { result in
                    DispatchQueue.main.async {
                        self.handle(result, shouldEndRefreshing: true)
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self.view?.endRefreshing()
                    self.view?.showError(message: "Не удалось обновить ленту. Проверьте подключение к интернету.")
                }
            }
        }
    }
    
    private func handle(_ result: Result<[PostEntity], Error>, shouldEndRefreshing: Bool) {
        view?.hideLoading()
        if shouldEndRefreshing {
            view?.endRefreshing()
        }
        switch result {
        case .success(let entities):
            print("HANDLE SUCCESS, count =", entities.count)
            view?.display(posts: entities)
        case .failure(let error):
            print("HANDLE ERROR:", error)
            view?.showError(message: error.localizedDescription)
        }
    }
}

