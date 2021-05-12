//
//  ViewController.swift
//  RxSwift_TableViewEx
//
//  Created by 윤성호 on 2021/05/11.
//

import UIKit
import RxSwift

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

struct Member: Decodable {
    
    var id: Int
    var name: String
    var avatar: String
    var job: String
    var age: Int
}

class ViewController: UITableViewController {
    
    var disposeBag = DisposeBag()
    
    var memberList: [Member] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadMemberList { (list) in
            self.memberList = list
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    // 리스트 불러오기
    func loadMemberList(completed: @escaping ([Member]) -> Void) {
        
        let task = URLSession.shared.dataTask(with: URL(string: MEMBER_LIST_URL)!) { (data, response, error) in
            
            // error가 발생하면 종료
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            // data값이 있는지 확인하고, data가 json 일때, swift 데이터 타입으로 변환
            // 기존 json 변환 방법
//            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                return
//            }
            
            // JSONDecoder를 통해 구조체에 decoding되는 방식
            // 단, json과 1:1로 모두 매핑이 되야함
            guard let data = data, let json = try? JSONDecoder().decode([Member].self, from: data) else {
                return
            }
            
            // 받아온 json 파일 처리
            completed(json)
//            print(json)
            
        }
        task.resume()   // 종료될 경우 다시 시작
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailSegue",
           let detailVC = segue.destination as? DetailViewController,
           let parmeter = sender as? Member {
            
            detailVC.member = parmeter
        }
    }

}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let member = memberList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberListCell") as? MemberListCell
        loadMemberAvatar(url: member.avatar) { (img) in
            DispatchQueue.main.async {
                cell?.avatarImgView.image = img
            }
        }
        cell?.nameLabel.text = member.name
        cell?.jobLabel.text = member.job
        cell?.ageLabel.text = "(\(member.age))"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = memberList[indexPath.row]
        performSegue(withIdentifier: "goDetailSegue", sender: member)
    }
}

