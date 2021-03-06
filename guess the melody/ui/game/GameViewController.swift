//
//  GameViewController.swift
//  guess the melody
//
//  Created by Vlad on 04.05.2018.
//  Copyright © 2018 VZ. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var musicPlateView: MusicPlateView! {
        didSet {
            musicPlateView.clipsToBounds = true
        }
    }
    @IBOutlet weak var musicPlateAlbumViewsContainer: UIView!
    
    @IBOutlet weak var answersView: AnswersView!
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.addTarget(self, action: #selector(self.closeButtonAction), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var playAndPauseButton: UIButton! {
        didSet {
            playAndPauseButton.addTarget(self, action: #selector(self.playAndPauseButtonAction), for: .touchUpInside)
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!

    private let rightAnswerView = RightAnswerView()
    private var rightAnswerViewBottomConstrain = NSLayoutConstraint()
    
    private let wrongAnswerView = WrongAnswerView()
    private var wrongAnswerViewBottomConstrain = NSLayoutConstraint()
    
    var model: GTMGameModel!
    
    private let activity = NVActivityIndicatorView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 10, y: 36, width: 20, height: 20), type: .lineScale, color: UIColor.red, padding: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.configurePlayAndPauseButton), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.view.backgroundColor = Colors.background
        activity.color = Colors.alertLoseBackground
        
        setupRightAnswerView()
        rightAnswerView.nextAction = { [weak self] in
            self?.model.setNextQuestion()
            self?.hideRightAnswerView()
        }
        
        setupWrongAnswerView()
        wrongAnswerView.nextAction = { [weak self] in
            self?.model.setNextQuestion()
            self?.hideWrongAnswerView()
        }
        
        answersView.userDidAnswer = { [unowned self] (index) in
            return self.useDidAnswer(index: index)
        }
        
        answersView.userDidSwap = { [unowned self] in
            return self.useDidSwap()
        }
        
        model.delegate = self
        
        self.view.addSubview(activity)
        model.startGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        answersView.isHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurePlayAndPauseButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.stopGame()
        answersView.isHidden = true
    }

    private func showWinOrLoseVC(isUserWin: Bool) {
        if let vc = LevelEndViewController.storyboardInstance {
            vc.result = model.getResult()
            vc.isUserWin = isUserWin
            vc.completion = { [weak self] action in
                self?.hideRightAnswerView()
                self?.hideWrongAnswerView()
                
                switch action {
                case .goToMenu:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .goToNextLevel:
                    self?.setNextLevel()
                case .palyAgain:
                    self?.playAgain()
                }
            }
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func setNextLevel() {
        model.setNextLevel()
        model.startGame()
    }
    
    private func playAgain() {
        model.playAgain()
        model.startGame()
    }
    
    private func setupRightAnswerView() {
        self.view.addSubview(rightAnswerView)
        rightAnswerView.translatesAutoresizingMaskIntoConstraints = false
        rightAnswerView.layer.cornerRadius = 4
        
        rightAnswerViewBottomConstrain = rightAnswerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 200)
        
        NSLayoutConstraint.activate([rightAnswerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8), rightAnswerView.heightAnchor.constraint(equalToConstant: 120), rightAnswerViewBottomConstrain, rightAnswerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 1)])
    }
    
    private func setupWrongAnswerView() {
        self.view.addSubview(wrongAnswerView)
        wrongAnswerView.translatesAutoresizingMaskIntoConstraints = false
        wrongAnswerView.layer.cornerRadius = 4
        
        wrongAnswerViewBottomConstrain = wrongAnswerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 200)
        
        NSLayoutConstraint.activate([wrongAnswerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8), wrongAnswerView.heightAnchor.constraint(equalToConstant: 120), wrongAnswerViewBottomConstrain, wrongAnswerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 1)])
    }
    
    private func setLife(life: Int) {
        livesLabel.text = "\(String(life))" + "/" + "\(String(model.totalLives()))"
    }
    
    private func setRightAnswers(rightAnswers: Int) {
        answersLabel.text = "\(String(rightAnswers))" + "/" + "\(String(model.totalAnswers()))"
    }

    private func setQuestion() {
        var data = [GTMAnswerData]()
        for index in 0..<4 {
            data.append(model.answerFor(index: index))
        }
        answersView.setData(data: data)
    }

    private func startSpin() {
        musicPlateView.startSpin()
    }
    
    private func stopSpin() {
        musicPlateView.stopSpin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit - GameViewController")
    }
}

@objc extension GameViewController {
    private func useDidAnswer(index: Int) -> Bool {
        if let isCorrect = model.userDidAnswer(index: index) {
            if isCorrect {
                showRightAnswerView()
            } else {
                showWrongAnswerView()
            }
        }
        return !model.isGameOnPause
    }
    
    private func useDidSwap() -> Bool {
        model.userDidSwap()
        return !model.isGameOnPause
    }
    
    private func closeButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func playAndPauseButtonAction() {
        if model.isGameOnPause {
            model.continueGame()
        } else {
            model.stopGame()
        }
        configurePlayAndPauseButton()
    }
    
    private func configurePlayAndPauseButton() {
        if model.isGameOnPause {
            playAndPauseButton.setTitle("Play", for: .normal)
        } else {
            playAndPauseButton.setTitle("Pause", for: .normal)
        }
    }
}

extension GameViewController {
    private func showRightAnswerView() {
        UIView.animate(withDuration: 0.3) {
            self.rightAnswerViewBottomConstrain.constant = -20
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideRightAnswerView() {
        UIView.animate(withDuration: 0.3) {
            self.rightAnswerViewBottomConstrain.constant = 200
            self.view.layoutIfNeeded()
        }
    }
    
    private func showWrongAnswerView() {
        UIView.animate(withDuration: 0.3) {
            self.wrongAnswerViewBottomConstrain.constant = -20
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideWrongAnswerView() {
        UIView.animate(withDuration: 0.3) {
            self.wrongAnswerViewBottomConstrain.constant = 200
            self.view.layoutIfNeeded()
        }
    }
}

extension GameViewController: GTMGameModelDelegate {
    func updateUI(_ swaps: Int, _ life: Int, _ rightAnswers: Int) {
        let swapsTotal = self.model.swapsTotal()
        self.answersView.configureSwapButton(swapsLeft: swaps, swapsTotal: swapsTotal)
        self.setLife(life: life)
        self.setRightAnswers(rightAnswers: rightAnswers)
        
        self.setQuestion()
    }
    
    func updateTime(_ time: String) {
        DispatchQueue.main.async {
            self.timeLabel.text = time
        }
    }
    
    func startStopSpin(_ isSpinning: Bool) {
        if isSpinning {
            self.startSpin()
        } else {
            self.stopSpin()
        }
    }
    
    func startStopLoading(_ isLoading: Bool) {
        self.loadingLabel.isHidden = !isLoading
        self.answersView.isLock = isLoading
        if isLoading {
            self.activity.startAnimating()
            self.activity.isHidden = false
        } else {
            self.activity.stopAnimating()
            self.activity.isHidden = true
        }
    }
    
    func timeIsOver() {
        self.showWrongAnswerView()
    }
    
    func gameOver(_ isUserWin: Bool) {
        self.showWinOrLoseVC(isUserWin: isUserWin)
    }
    
    func itWasLastLevel() {
        
    }
}

extension GameViewController: StoryboardInstanceable {
    static var storyboardName: StoryboardList = .game
}
