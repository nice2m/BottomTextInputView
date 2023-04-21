//
//  DemoIndexController.swift
//  BottomInputView
//
//  Created by hither on 2023/4/21.
//

import UIKit


class DemoIndexController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        view.backgroundColor = .white
    }
}

extension DemoIndexController {
    var data: [ DemoSection ] {
        return [
            DemoSection(title: "UI", demos: [
                Demo(title: "bottomInputView", des: "底部输入控件", vc: BottomInputViewController.self),
            Demo(title: "banner", des: "banner 实现", vc: ORSBannerDemoController.self)
            ])
        ]
    }
}

extension DemoIndexController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let model = data[indexPath.section].demos[indexPath.row]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.des
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = data[indexPath.section].demos[indexPath.row]
        let vc = model.vc.init()
        vc.title = model.title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let outerView = UIView()
        
        let view = UILabel()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        view.text = data[section].title
        outerView.addSubview(view)
        view.frame = .init(x: 16, y: 0, width: 100, height: 32)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
}
