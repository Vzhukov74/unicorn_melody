//
//  RightAnswerView.swift
//  guess the melody
//
//  Created by Vlad on 17.05.2018.
//  Copyright © 2018 VZ. All rights reserved.
//

import UIKit

class RightAnswerView: UIView {

    var nextAction: (() -> Void)?
    
    private let nextButton = UIButton()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(nextButton)
        self.addSubview(titleLabel)
        
        setConstrains()
        
        titleLabel.text = "It is correct answer!"
        titleLabel.textAlignment = .center
        nextButton.setTitle("next question", for: .normal)
        
        nextButton.addTarget(self, action: #selector(self.nextButtonAction), for: .touchUpInside)
    }
    
    private func setConstrains() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nextButtonConstrains = [nextButton.widthAnchor.constraint(equalToConstant: 200), nextButton.heightAnchor.constraint(equalToConstant: 50), nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)]
        let titleLabelConstrains = [titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20), titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20), titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)]
        
        NSLayoutConstraint.activate(nextButtonConstrains)
        NSLayoutConstraint.activate(titleLabelConstrains)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

@objc extension RightAnswerView {
    func nextButtonAction() {
        nextAction?()
    }
}