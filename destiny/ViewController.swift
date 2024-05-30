//
//  ViewController.swift
//  destiny
//
//  Created by Ueta, Lucas T on 9/18/23.
//

import UIKit

class ViewController: UIViewController {
        
    var graphics: [String: String]?, story: [Chapter]?, chapter: Chapter?
    let graphic = UILabel(), info = UILabel(), pathStack = UIStackView()

    let font = UIFont(name: "B612Mono-Regular", size: 16)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // importing JSON
        if let data = FileLoader.readLocalFile("graphics") { graphics = FileLoader.loadGraphics(data) }
        if let moreData = FileLoader.readLocalFile("story") { story = FileLoader.loadStory(moreData) }
        
        for family in UIFont.familyNames {
            print("family:", family)
            for font in UIFont.fontNames(forFamilyName: family) {
                print("font:", font)
            }
        }

        // UI/X
        view.layer.backgroundColor = UIColor.black.cgColor
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 70
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        for label in [ graphic, info ] {
            label.textColor = .green
            label.font = font
            label.numberOfLines = 0
        }
        
        stack.addArrangedSubview(graphic)
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 18 // supposed to be font.lineHeight
        stack.addArrangedSubview(textStack)
        textStack.addArrangedSubview(info)
        
        pathStack.axis = .vertical
        pathStack.spacing = 18
        textStack.addArrangedSubview(pathStack)
        
        // start first chapter
        loadEverything(0)
    }
    
    
    func loadEverything(_ chapterId: Int, characterDelay: TimeInterval = 2.5) {
        chapter = story![chapterId]
        
        // clear
        graphic.text = ""
        info.text = ""
        for path in pathStack.arrangedSubviews { path.removeFromSuperview() }
        
        // create new buttons (but don't type yet)
        var buttons: [UIButton] = []
        for option in chapter!.next {
            let button = UIButton()
            button.setTitleColor(.green, for: .normal)
            button.titleLabel?.font = self.font
            button.titleLabel?.numberOfLines = 0
            button.contentHorizontalAlignment = .left
            button.sizeToFit()

            button.tag = option.next
            button.addTarget(self, action: #selector(self.pick(_:)), for: .touchUpInside)
            self.pathStack.addArrangedSubview(button)
            buttons.append(button)
        }

        let writingTask = DispatchWorkItem { [weak graphic] in // I still don't understand this weak part, but oh well
            
            (self.graphics![self.chapter!.graphic ?? ""] ?? "").forEach { char in
                DispatchQueue.main.async { self.graphic.text?.append(char) }
                Thread.sleep(forTimeInterval: characterDelay / 100)
            }

            (self.chapter!.text ?? "").forEach { char in
                DispatchQueue.main.async { self.info.text?.append(char) }
                Thread.sleep(forTimeInterval: characterDelay / 100)
            }
            
            for i in 0..<buttons.count {
                let button = buttons[i], option = self.chapter!.next[i]
                
                for j in 1...option.text.count {
                    DispatchQueue.main.async { button.setTitle(String(option.text.prefix(j)), for: .normal) }
                    Thread.sleep(forTimeInterval: characterDelay / 100)
        }}}
        
        let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
    
    @objc func pick(_ sender: UIButton) {
        loadEverything(sender.tag)
    }
}

