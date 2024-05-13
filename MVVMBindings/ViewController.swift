//
//  ViewController.swift
//  MVVMBindings
//
//  Created by Kanokchai Amaphut on 11/5/2567 BE.
//

import UIKit

// Obserable
class Obeservale<T> {
    var value: T? {
        didSet {
            listeners.forEach {
                $0(value)
            }
        }
    }
    
    init(value: T?) {
        self.value = value
    }
    
    private var listeners: [((T?) -> Void)] = []
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listeners.append(listener)
    }
}
// Model

struct User: Codable {
    let name: String
}
// ViewModels

struct UserListViewModel {
    var users: Obeservale<[UserTableViewCellViewModel]> = Obeservale(value: [])
}

struct UserTableViewCellViewModel {
    let name: String
}
// Controller

class ViewController: UIViewController, UITableViewDataSource {
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var viewModel = UserListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        viewModel.users.bind { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        fetchData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let userModel = try JSONDecoder().decode([User].self, from: data)
                
                self.viewModel.users.value = userModel.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            } catch {
                
            }
        }
        task.resume()
    }
}

