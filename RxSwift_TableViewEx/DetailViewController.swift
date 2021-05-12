//
//  DetailViewController.swift
//  RxSwift_TableViewEx
//
//  Created by 윤성호 on 2021/05/11.
//

import UIKit

class DetailViewController: UIViewController {
    
    var member: Member?
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(member)
        
        loadMemberAvatar(url: member!.avatar) { (img) in
            DispatchQueue.main.async {
                self.avatarImgView.image = img
            }
        }
        idLabel.text = " # \(member!.id)"
        nameLabel.text = member!.name
        jobLabel.text = member!.job
        ageLabel.text = "(\(member!.age))"
        
    }
    
    // 이미지 불러오기
    func loadMemberAvatar(url: String, completed: @escaping (UIImage) -> Void) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // 에러 발생시 종료
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            // data nil 처리
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            completed(image)
            
        }
        task.resume()
    }
    

}
