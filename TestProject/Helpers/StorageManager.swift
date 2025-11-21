//
//  StorageManager.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 17.11.2025.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private let networkManager = NetworkManager.shared
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Posts
    
    func fetchInitialPosts(completion: @escaping (Result<[PostEntity], Error>) -> Void) {
        
        fetchPosts { [weak self] localResult in
            guard let self = self else { return }
            switch localResult {
            case .success(let localPosts) where !localPosts.isEmpty:
                completion(.success(localPosts))
                self.networkManager.fetchPosts { [weak self] networkResult in
                    guard let self = self else { return }
                    switch networkResult {
                    case .success(let dtos):
                        self.saveToCoreData(postDto: dtos) { _ in }
                    case .failure:
                        break
                    }
                }
            default:
                self.networkManager.fetchPosts { [weak self] networkResult in
                    guard let self = self else { return }
                    switch networkResult {
                    case .success(let dtos):
                        self.saveToCoreData(postDto: dtos, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func fetchPosts(completion: @escaping (Result<[PostEntity], Error>) -> Void) {
        print("fetchPosts from Core Data")
        persistentContainer.viewContext.perform {
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            do {
                let posts = try self.persistentContainer.viewContext.fetch(request)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func saveToCoreData(postDto: [PostDTO], completion: @escaping (Result<[PostEntity], Error>) -> Void) {
        persistentContainer.viewContext.perform {
            var posts = [PostEntity]()

            for dto in postDto {
                let newPost = PostEntity(context: self.persistentContainer.viewContext)
                newPost.id = Int16(dto.id)
                newPost.userId = Int16(dto.userId)
                newPost.title = dto.title
                newPost.body = dto.body
                posts.append(newPost)
            }

            do {
                try self.persistentContainer.viewContext.save()
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
            
            print("saveToCoreData, dtos:", postDto.count)
            print("created posts:", posts.count)
        }
    }

    // MARK: - Likes
    
    private func fetchLike(postId: Int16, userId: String, context: NSManagedObjectContext) throws -> LikeEntity? {
        let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "postId == %d", postId),
            NSPredicate(format: "userId == %@", userId)
        ])
        let results = try context.fetch(request)
        return results.first
    }
    
    func toggleLike(for postId: Int16, userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            do {
                if let existing = try self.fetchLike(postId: postId, userId: userId, context: context) {
                    context.delete(existing)
                    try context.save()
                    completion(.success(false)) // лайк снят
                } else {
                    let like = LikeEntity(context: context)
                    like.id = UUID()
                    like.postId = postId
                    like.userId = userId
                    like.createdAt = Date()
                    try context.save()
                    completion(.success(true)) // лайк поставлен
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func isPostLiked(postId: Int16, userId: String, completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            do {
                let like = try self.fetchLike(postId: postId, userId: userId, context: context)
                completion(like != nil)
            } catch {
                completion(false)
            }
        }
    }
    
    func likesCount(for postId: Int16, completion: @escaping (Int) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            let request: NSFetchRequest<LikeEntity> = LikeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "postId == %d", postId)
            do {
                let likes = try context.fetch(request)
                completion(likes.count)
            } catch {
                completion(0)
            }
        }
    }
}
