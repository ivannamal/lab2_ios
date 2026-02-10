//
//  ViewController.swift
//  MyFisrtUIKitApp
//
//  Created by Ivanna Malashchuk on 04.02.2026.
//

import UIKit
import SDWebImage

struct PostsResponse: Codable {
    let posts: [Post]
}

struct Post: Codable {
    let text: String
    let ups: Int
    let comments: [Comment]
    let created_at: Double
    let title: String
    let id: String
    let username:String
    let domain: String
    let downs: Int
    let image_url: String
}

struct Comment: Codable {
    let username: String
    let text: String
    let id: String
    let post_id: String
    let downs: Int
    let ups: Int
}
let postNum = Int.random(in: 0..<20)

func fetchPost () async throws -> Post{
    let (data, _) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:8080/posts/")!)
    guard let responce = try? JSONDecoder().decode(PostsResponse.self, from: data) else { fatalError("Couldn't decode response") }

    let post = responce.posts[postNum]
    print(post.image_url)

    return post
}

class ViewController: UIViewController {


    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var comments: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var domain: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var usernameOfUser: UILabel!
    @IBOutlet weak var upvotes: UIButton!
    @IBOutlet weak var bookmark: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var isBookmarked: Bool = false
    

    @IBAction func bookmarkTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        isBookmarked = sender.isSelected
    }

    
    func fetchingImageHelper() async throws  {
        do{
            let post = try await fetchPost()
            let url = post.image_url
            image.sd_setImage(with: URL(string: url))
        }
        catch {
            throw error
        }
    }
    func fetchingEverythingElse() async throws  {
        do{
            let post = try await fetchPost()
            let username = post.username
            let title = post.title
            let likes = post.ups-post.downs
            let comments = post.comments.count
            let domain = post.domain
            let timestamp = post.created_at
            let date = Int(timestamp)
            let now = Int(Date().timeIntervalSince1970)
            let difference = Int(now - date)
            if difference>86400{
                timeAgo.text = "\(difference / 86400)d"
            }
            else {
                timeAgo.text = "\(difference / 3600)h"
            }
            
            self.upvotes.setTitle("\(likes)", for: .normal)
            self.comments.setTitle("\(comments)", for: .normal)
        
            self.usernameOfUser.text = username
            self.titleLabel.text = title
            self.domain.text = domain
        }
        catch{
            throw error
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task{
            try await fetchingEverythingElse()
        }
        Task{
             try await fetchingImageHelper()
        }
        bookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)

    }


}

