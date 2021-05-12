//
//  MemberListCell.swift
//  RxSwift_TableViewEx
//
//  Created by 윤성호 on 2021/05/11.
//

import UIKit
import RxCocoa
import RxSwift

class MemberListCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 재사용 되기 전에 호출되는 매소드
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setData(_ member: Member) {
        loadMemberAvatar(url: member.avatar)
            .observe(on: MainScheduler.instance)
            .bind(to: avatarImgView.rx.image)       // bind : 단순히 onNext만 수행할 때
            .disposed(by: disposeBag)
        avatarImgView.image = nil
        nameLabel.text = member.name
        jobLabel.text = member.job
        ageLabel.text = "(\(member.age))"
    }
    
    // 이미지 불러오기
    func loadMemberAvatar(url: String) -> Observable<UIImage?> {
        
        return Observable.create { emitter in
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                
                // 에러 발생시 종료
                if let err = error {
                    print(err.localizedDescription)
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
