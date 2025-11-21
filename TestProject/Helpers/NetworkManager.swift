//
//  NetworkManager.swift
//  TestProject
//
//  Created by Нурик  Генджалиев   on 17.11.2025.
//

import Foundation
import UIKit

struct PostDTO: Decodable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    
    func fetchPosts(completion: @escaping (Result<[PostDTO], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("posts")
        
        print("NetworkManager.fetchPosts start")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            print("NetworkManager.fetchPosts completion, error:", error as Any)
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Empty response"])))
                }
                return
            }
            do {
                let posts = try JSONDecoder().decode([PostDTO].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    func loadAvatar(for userId: Int16, completion: @escaping (UIImage?) -> Void) {
        let id = Int(userId)
        let urlString = "https://picsum.photos/seed/\(id)/80/80"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
