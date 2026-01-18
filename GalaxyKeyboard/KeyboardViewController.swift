//
//  KeyboardViewController.swift
//  GalaxyKeyboard
//
//  Created by Nodari L on 18.01.26.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    private var isShifted = false
    private var isCapsLocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // Number row
        let numberRow = createNumberRow()
        stackView.addArrangedSubview(numberRow)
        
        // QWERTY rows
        let firstRow = createLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"])
        let secondRow = createLetterRow(["a", "s", "d", "f", "g", "h", "j", "k", "l"])
        let thirdRow = createThirdRow()
        let bottomRow = createBottomRow()
        
        stackView.addArrangedSubview(firstRow)
        stackView.addArrangedSubview(secondRow)
        stackView.addArrangedSubview(thirdRow)
        stackView.addArrangedSubview(bottomRow)
    }
    
    private func createNumberRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        for number in numbers {
            let button = createKeyButton(title: number, action: #selector(numberKeyPressed(_:)))
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createLetterRow(_ letters: [String]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        for letter in letters {
            let button = createKeyButton(title: letter, action: #selector(letterKeyPressed(_:)))
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createThirdRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        let shiftButton = createSpecialButton(title: "⇧", action: #selector(shiftPressed))
        shiftButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let letterStackView = UIStackView()
        letterStackView.axis = .horizontal
        letterStackView.distribution = .fillEqually
        letterStackView.spacing = 4
        
        let letters = ["z", "x", "c", "v", "b", "n", "m"]
        for letter in letters {
            let button = createKeyButton(title: letter, action: #selector(letterKeyPressed(_:)))
            letterStackView.addArrangedSubview(button)
        }
        
        let deleteButton = createSpecialButton(title: "⌫", action: #selector(deletePressed))
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        stackView.addArrangedSubview(shiftButton)
        stackView.addArrangedSubview(letterStackView)
        stackView.addArrangedSubview(deleteButton)
        
        return stackView
    }
    
    private func createBottomRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        let nextKeyboardButton = createSpecialButton(title: "🌐", action: #selector(handleInputModeList(from:with:)))
        nextKeyboardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        
        let spaceButton = createSpecialButton(title: "space", action: #selector(spacePressed))
        
        let returnButton = createSpecialButton(title: "return", action: #selector(returnPressed))
        returnButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        stackView.addArrangedSubview(nextKeyboardButton)
        stackView.addArrangedSubview(spaceButton)
        stackView.addArrangedSubview(returnButton)
        
        return stackView
    }
    
    private func createKeyButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemGray4
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }
    
    private func createSpecialButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.systemGray3
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }
    
    @objc private func numberKeyPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        textDocumentProxy.insertText(title)
    }
    
    @objc private func letterKeyPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        let text: String
        if isShifted || isCapsLocked {
            text = title.uppercased()
        } else {
            text = title.lowercased()
        }
        
        textDocumentProxy.insertText(text)
        
        if isShifted && !isCapsLocked {
            isShifted = false
            updateShiftState()
        }
    }
    
    @objc private func shiftPressed() {
        if isShifted {
            isCapsLocked = !isCapsLocked
            if isCapsLocked {
                isShifted = true
            } else {
                isShifted = false
            }
        } else {
            isShifted = true
            isCapsLocked = false
        }
        updateShiftState()
    }
    
    @objc private func deletePressed() {
        textDocumentProxy.deleteBackward()
    }
    
    @objc private func spacePressed() {
        textDocumentProxy.insertText(" ")
    }
    
    @objc private func returnPressed() {
        textDocumentProxy.insertText("\n")
    }
    
    private func updateShiftState() {
        for subview in view.subviews {
            updateShiftStateRecursively(in: subview)
        }
    }
    
    private func updateShiftStateRecursively(in view: UIView) {
        if let button = view as? UIButton,
           let title = button.currentTitle,
           title.count == 1,
           title.first?.isLetter == true {
            
            if isShifted || isCapsLocked {
                button.setTitle(title.uppercased(), for: .normal)
            } else {
                button.setTitle(title.lowercased(), for: .normal)
            }
        }
        
        for subview in view.subviews {
            updateShiftStateRecursively(in: subview)
        }
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        updateAppearance()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateAppearance()
    }
    
    private func updateAppearance() {
        let isDarkMode = textDocumentProxy.keyboardAppearance == .dark
        let backgroundColor = isDarkMode ? UIColor.black : UIColor.systemGray6
        let keyColor = isDarkMode ? UIColor.systemGray3 : UIColor.systemGray4
        let specialKeyColor = isDarkMode ? UIColor.systemGray2 : UIColor.systemGray3
        let textColor = isDarkMode ? UIColor.white : UIColor.black
        
        view.backgroundColor = backgroundColor
        
        updateColorsRecursively(in: view, keyColor: keyColor, specialKeyColor: specialKeyColor, textColor: textColor)
    }
    
    private func updateColorsRecursively(in view: UIView, keyColor: UIColor, specialKeyColor: UIColor, textColor: UIColor) {
        if let button = view as? UIButton {
            if let title = button.currentTitle {
                if title == "⇧" || title == "⌫" || title == "🌐" || title == "space" || title == "return" {
                    button.backgroundColor = specialKeyColor
                } else {
                    button.backgroundColor = keyColor
                }
                button.setTitleColor(textColor, for: .normal)
            }
        }
        
        for subview in view.subviews {
            updateColorsRecursively(in: subview, keyColor: keyColor, specialKeyColor: specialKeyColor, textColor: textColor)
        }
    }
}
