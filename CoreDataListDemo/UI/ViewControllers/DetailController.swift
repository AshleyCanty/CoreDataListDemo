//
//  SecondController.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/19/24.
//

import UIKit

class DetailController: UIViewController {
    
    private lazy var labelModifier: ((UILabel, UIColor, UIFont)->()) = { label, textColor, font in
        label.textColor = textColor
        label.font = font
        label.textAlignment = .center
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        labelModifier(label, .black, UIFont.systemFont(ofSize: 20, weight: .bold))
        return label
    }()
    
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        labelModifier(label, .systemBlue, UIFont.systemFont(ofSize: 18, weight: .medium))
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        labelModifier(label, .systemBlue, UIFont.systemFont(ofSize: 18, weight: .medium))
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel, genderLabel, ageLabel])
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    var name = ""
    var gender = ""
    var age = ""
    
    init(name: String, gender: String, age: Int) {
        self.name = name
        self.gender = gender
        self.age = String(age)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Detail Controller"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func configureViews() {
        nameLabel.text = name
        genderLabel.text = "Gender: \(gender)"
        ageLabel.text = "Age: \(age)"
        
        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
