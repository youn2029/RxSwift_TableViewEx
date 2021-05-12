//
//  DetailViewController.swift
//  RxSwift_TableViewEx
//
//  Created by 윤성호 on 2021/05/11.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    var member: Member?
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let member = member {
            setData(member)
        }
    }
    
    func setData(_ member: Member) {
        loadMemberAvatar(url: member.avatar)
            .observe(on: MainScheduler.instance)
            .bind(to: avatarImgView.rx.image)
            .disposed(by: disposeBag)
        idLabel.text = " # \(member.id)"
        avatarImgView.image = nil
        nameLabel.text = member.name
        jobLabel.text = member.job
        ageLabel.text = "(\(member.age))"
    }
    
    // 이미지 불러오기
    func loadMemberAvatar(url: String) -> Observable<UIImage?> {
        
        return Observable.create{ emitter in
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                
                // 에러 발생시 종료
                if let err = error {
                    emitter.onError(err)
                    return
                }
                
                // data nil 처리
                guard let data = data, let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
        
    }
    

}
