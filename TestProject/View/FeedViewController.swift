//
//  FeedViewController.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 17.11.2025.
//

import UIKit

protocol FeedViewInput: AnyObject {
    func display(posts: [PostEntity])
    func endRefreshing()
    func showLoading()
    func hideLoading()
    func showError(message: String)
}

class FeedViewController: UIViewController, FeedViewInput {
    private let tableView = UITableView()
    private var allPosts: [PostEntity] = []
    private var posts: [PostEntity] = []
    private var currentPage = 0
    private let pageSize = 20
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let storage = StorageManager.shared
    private let currentUserId = "user_1"
    private lazy var presenter = FeedPresenter(view: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Лента"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicator()
        presenter.viewDidLoad()
    }

    // Настройка таблицы
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: FeedCell.reuseIdentifier)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.alpha = 0
    }
    // Настройка индикатора загрузки
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func handleRefresh() {
        presenter.refreshRequested()
    }
    
    // MARK: - FeedViewInput
    func display(posts: [PostEntity]) {
        allPosts = posts
        currentPage = 0
        loadNextPage()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction],
                       animations: {
            self.tableView.alpha = 1
        }, completion: nil)
    }
    
    // Реализация пагинации
    func loadNextPage() {
        let start = currentPage * pageSize
        let end = min(start + pageSize, allPosts.count)
        guard start < end else { return }
        
        let nextSlice = allPosts[start..<end]
        if currentPage == 0 {
            posts = Array(nextSlice)
            tableView.reloadData()
        } else {
            let oldCount = posts.count
            posts.append(contentsOf: nextSlice)
            let newCount = posts.count
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0)}
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        currentPage += 1
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        cell.setLikeState(isLiked: false, likesCount: 0)
        
        // Реализация лайка
        storage.isPostLiked(postId: post.id, userId: currentUserId) { [weak self, weak cell] isLiked in
            guard let self = self, let cell = cell else { return }
            self.storage.likesCount(for: post.id) { [weak cell] count in
                guard let cell = cell else { return }
                DispatchQueue.main.async {
                    cell.setLikeState(isLiked: isLiked, likesCount: count)
                }
            }
        }
        cell.onLikeTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.storage.toggleLike(for: post.id, userId: self.currentUserId) { [weak self, weak cell] result in
                guard let self = self, let cell = cell else { return }
                switch result {
                case .success:
                    self.storage.isPostLiked(postId: post.id, userId: self.currentUserId) { [weak self, weak cell] isLiked in
                        guard let self = self, let cell = cell else { return }
                        self.storage.likesCount(for: post.id) { [weak cell] count in
                            guard let cell = cell else { return }
                            DispatchQueue.main.async {
                                cell.setLikeState(isLiked: isLiked, likesCount: count)
                            }
                        }
                    }
                case .failure(let error):
                    print("LIKE ERROR:", error)
                }
            }
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.size.height
        
        if offsetY > contentHeight - visibleHeight {
            loadNextPage()
        }
        
    }
}

