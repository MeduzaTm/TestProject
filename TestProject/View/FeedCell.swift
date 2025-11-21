//
//  FeedCell.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 19.11.2025.
//

import UIKit


class FeedCell: UITableViewCell {
    static let reuseIdentifier = "FeedCell"
    
    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private let likesLabel = UILabel()
    
    var onLikeTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(bodyLabel)
        cardView.addSubview(likeButton)
        cardView.addSubview(likesLabel)
        
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = false
        
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        
        bodyLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 3
        
        likeButton.setTitle("♡", for: .normal)
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        likeButton.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        
        likesLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        likesLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            likeButton.topAnchor.constraint(greaterThanOrEqualTo: bodyLabel.bottomAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            likeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),
            likesLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bodyLabel.leadingAnchor),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with post: PostEntity) {
        titleLabel.text = post.title
        bodyLabel.text = post.body
        loadAvatar(for: post)
    }
    
    func setLikeState(isLiked: Bool, likesCount: Int) {
        let title = isLiked ? "♥︎" : "♡"
        likeButton.setTitle(title, for: .normal)
        likesLabel.text = likesCount > 0 ? "\(likesCount)" : ""
    }
    
    private func loadAvatar(for post: PostEntity) {
        avatarImageView.image = nil
        NetworkManager.shared.loadAvatar(for: post.userId) { [weak self] image in
            guard let self = self else { return }
            self.avatarImageView.image = image
        }
    }
    
    @objc private func handleLikeTapped() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 3,
                           options: [.allowUserInteraction],
                           animations: {
                self.likeButton.transform = .identity
            }, completion: nil)
        })
        onLikeTapped?()
    }
}
