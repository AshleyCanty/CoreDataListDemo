//
//  ViewController.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/19/24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableCellDelegate {
    
    let personProvider = PersonProvider.shared
    var items: [Person]?
    
    lazy var table: UITableView = {
       let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViews()
        fetchPeople()
    }
    
    func fetchPeople() {
        do {
            try items = personProvider.fetchPeople()
            DispatchQueue.main.async { [weak self] in
                self?.table.reloadData()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.showAlertError(errorDetails: PersonProviderErrorMessage.fetchPeople.rawValue)
            }
        }
    }
    
    func configureViews() {
        view.backgroundColor = .systemCyan
        
        self.navigationItem.title = "Home"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    fileprivate func showAlertError(errorDetails: String) {
        let alert = UIAlertController(title: "Unable to complete request.", message: "Failed to \(errorDetails).", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func didPressEditButton(cell: TableViewCell) {
        guard let indexPath = table.indexPath(for: cell), let selectedPerson = items?[indexPath.row], let name = selectedPerson.name, let gender = selectedPerson.gender else { return }
        let detailVC = DetailController(name: name, gender: gender, age: Int(selectedPerson.age))
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func didTapAddButton(_ sender: Any) {
    
        let alert = UIAlertController(title: "Add Person", message: "What is their name, gender, and age?", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields?[0].placeholder = "Name"
        alert.textFields?[1].placeholder = "Gender"
        alert.textFields?[2].placeholder = "Age"
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            // TODO: Get the textfields for the alert
            let nameTextfield = alert.textFields?[0]
            let genderTextfield = alert.textFields?[1]
            let ageTextfield = alert.textFields?[2]
            
            let ageString = ageTextfield?.text ?? ""
            let age = Int(ageString) ?? 0
            
            // TODO: Create a person object
            do {
                try personProvider.createPerson(name: nameTextfield?.text, gender: genderTextfield?.text, age: age)
                // TODO: Re-fetch the data
                self.fetchPeople()
                alert.dismiss(animated: true)
            } catch {
                alert.dismiss(animated: true)
                showAlertError(errorDetails: PersonProviderErrorMessage.createPerson.rawValue)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id, for: indexPath) as! TableViewCell
        cell.titleLabel.text = items?[indexPath.row].name
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Selected Person
        guard let person = items?[indexPath.row] else { return }
        
        let alert = UIAlertController(title: "Edit Person", message: "Edit name, gender, or age:", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        let nameTextfield = alert.textFields?[0]
        nameTextfield?.keyboardType = .alphabet
        nameTextfield?.text = person.name

        let genderTextfield = alert.textFields?[1]
        genderTextfield?.keyboardType = .alphabet
        genderTextfield?.text = person.gender
        
        let ageTextfield = alert.textFields?[2]
        ageTextfield?.keyboardType = .numberPad
        ageTextfield?.text = String(person.age)
        
        // Configure button handler
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (action) in
   
            // TODO: Edit Person object
            let editedPerson = person
            editedPerson.name = alert.textFields?[0].text
            editedPerson.gender = alert.textFields?[1].text
            
            let ageString = alert.textFields?[2].text ?? ""
            editedPerson.age = Int64(ageString) ?? 0
            
            Task { [weak self] in
                guard let self = self else { return }
                
                do {
                    // TODO: Save changes
                    try await personProvider.updatePerson(editedPerson)
                    
                    // TODO: Re-Fetch Data
                    self.fetchPeople()
                    
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true)
                        self.showAlertError(errorDetails: PersonProviderErrorMessage.deletePerson.rawValue)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            
            Task {
                // TODO: Find person to remove
                guard let self = self, let selectedPerson = self.items?[indexPath.row] else { return }
            
                // TODO: Delete person object from items data source
                try await self.personProvider.deletePerson(selectedPerson, completion: {
                    // TODO: Re-fetch data
                    self.fetchPeople()
                })
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

