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
    private var isSymbolsMode = false
    private var isExtendedSymbolsMode = false
    private var letterButtons: [UIButton] = []
    private var lastShiftPressTime: TimeInterval = 0
    
    // Language support
    private var currentLanguage: KeyboardLanguage = .english
    private var spaceButton: UIButton?
    private var shiftButton: UIButton?
    
    // Long-press popup
    private var popupView: UIView?
    private var longPressTimer: Timer?
    
    enum KeyboardLanguage {
        case english
        case russian
        
        var displayName: String {
            switch self {
            case .english: return "EN"
            case .russian: return "РУ"
            }
        }
    }
    
    struct KeyboardLayout {
        let firstRow: [String]
        let secondRow: [String]
        let thirdRow: [String]
    }
    
    private func getKeyboardLayout(for language: KeyboardLanguage) -> KeyboardLayout {
        switch language {
        case .english:
            return KeyboardLayout(
                firstRow: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                secondRow: ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                thirdRow: ["z", "x", "c", "v", "b", "n", "m"]
            )
        case .russian:
            return KeyboardLayout(
                firstRow: ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"],
                secondRow: ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
                thirdRow: ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        // Remove all subviews first
        view.subviews.forEach { $0.removeFromSuperview() }
        letterButtons.removeAll()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // Number row (always present)
        let numberRow = createNumberRow()
        stackView.addArrangedSubview(numberRow)
        
        if isSymbolsMode {
            if isExtendedSymbolsMode {
                // Extended symbol rows (2/2 mode)
                let firstRow = createSymbolRow(["`", "~", "\\", "|", "{", "}", "€", "£", "¥", "₩"])
                let secondRow = createSymbolRow(["°", "•", "○", "●", "□", "■", "♠", "♥", "♦", "♣"])
                let thirdRow = createExtendedSymbolThirdRow()
                let bottomRow = createBottomRow()
                
                stackView.addArrangedSubview(firstRow)
                stackView.addArrangedSubview(secondRow)
                stackView.addArrangedSubview(thirdRow)
                stackView.addArrangedSubview(bottomRow)
            } else {
                // Regular symbol rows (1/2 mode)
                let firstRow = createSymbolRow(["+", "×", "÷", "=", "/", "_", "<", ">", "[", "]"])
                let secondRow = createSymbolRow(["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"])
                let thirdRow = createSymbolThirdRow()
                let bottomRow = createBottomRow()
                
                stackView.addArrangedSubview(firstRow)
                stackView.addArrangedSubview(secondRow)
                stackView.addArrangedSubview(thirdRow)
                stackView.addArrangedSubview(bottomRow)
            }
        } else {
            // Letter rows based on current language
            let layout = getKeyboardLayout(for: currentLanguage)
            let firstRow = createLetterRow(layout.firstRow)
            let secondRow = createLetterRow(layout.secondRow)
            let thirdRow = createThirdRow(layout.thirdRow)
            let bottomRow = createBottomRow()
            
            stackView.addArrangedSubview(firstRow)
            stackView.addArrangedSubview(secondRow)
            stackView.addArrangedSubview(thirdRow)
            stackView.addArrangedSubview(bottomRow)
        }
    }
    
    private func createNumberRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
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
        stackView.spacing = 6
        
        for letter in letters {
            // Always display uppercase letters on buttons
            let displayLetter = letter.uppercased()
            let button = createKeyButton(title: displayLetter, action: #selector(letterKeyPressed(_:)))
            // Store the original lowercase letter for input logic
            button.accessibilityIdentifier = letter.lowercased()
            
            // Add long-press for ь key in Russian keyboard
            if currentLanguage == .russian && (letter.lowercased() == "ь") {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(softSignLongPressed(_:)))
                longPressGesture.minimumPressDuration = 0.5
                button.addGestureRecognizer(longPressGesture)
            }
            
            letterButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createSymbolRow(_ symbols: [String]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
        for symbol in symbols {
            let button = createKeyButton(title: symbol, action: #selector(symbolRowKeyPressed(_:)))
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createSymbolThirdRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
        let symbols = ["1/2", "-", "'", "\"", ":", ";", ",", "?", "⌫"]
        for symbol in symbols {
            if symbol == "⌫" {
                let deleteButton = createSpecialButton(title: symbol, action: #selector(deletePressed))
                stackView.addArrangedSubview(deleteButton)
            } else if symbol == "1/2" {
                let toggleButton = createKeyButton(title: symbol, action: #selector(toggleExtendedSymbols))
                stackView.addArrangedSubview(toggleButton)
            } else {
                let button = createKeyButton(title: symbol, action: #selector(symbolRowKeyPressed(_:)))
                stackView.addArrangedSubview(button)
            }
        }
        
        return stackView
    }
    
    private func createExtendedSymbolThirdRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
        let symbols = ["2/2", "☆", "■", "¤","《","》", "¡", "¿", "⌫"]
        for symbol in symbols {
            if symbol == "⌫" {
                let deleteButton = createSpecialButton(title: symbol, action: #selector(deletePressed))
                stackView.addArrangedSubview(deleteButton)
            } else if symbol == "2/2" {
                let toggleButton = createKeyButton(title: symbol, action: #selector(toggleExtendedSymbols))
                stackView.addArrangedSubview(toggleButton)
            } else {
                let button = createKeyButton(title: symbol, action: #selector(symbolRowKeyPressed(_:)))
                stackView.addArrangedSubview(button)
            }
        }
        
        return stackView
    }
    
    private func createThirdRow(_ letters: [String]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6
        
        let shiftButton = createSpecialButton(title: "⇧", action: #selector(shiftPressed))
        self.shiftButton = shiftButton
        updateShiftButtonAppearance()
        
        for letter in letters {
            // Always display uppercase letters on buttons
            let displayLetter = letter.uppercased()
            let button = createKeyButton(title: displayLetter, action: #selector(letterKeyPressed(_:)))
            // Store the original lowercase letter for input logic
            button.accessibilityIdentifier = letter.lowercased()
            
            // Add long-press for ь key in Russian keyboard
            if currentLanguage == .russian && (letter.lowercased() == "ь") {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(softSignLongPressed(_:)))
                longPressGesture.minimumPressDuration = 0.5
                button.addGestureRecognizer(longPressGesture)
            }
            
            letterButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        let deleteButton = createSpecialButton(title: "⌫", action: #selector(deletePressed))
        
        stackView.insertArrangedSubview(shiftButton, at: 0)
        stackView.addArrangedSubview(deleteButton)
        
        return stackView
    }
    
    private func createBottomRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        
        let symbolButtonTitle = isSymbolsMode ? "ABC" : "!#1"
        let symbolButton = createKeyButton(title: symbolButtonTitle, action: #selector(toggleSymbolsMode))
        symbolButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let commaButton = createKeyButton(title: ",", action: #selector(punctuationKeyPressed(_:)))
        commaButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let spaceButton = createSpecialButton(title: "\(currentLanguage.displayName)", action: #selector(spacePressed))
        self.spaceButton = spaceButton
        setupSpaceButtonGestures(spaceButton)
        
        let dotButton = createKeyButton(title: ".", action: #selector(punctuationKeyPressed(_:)))
        dotButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let returnButton = createSpecialButton(title: "↵", action: #selector(returnPressed))
        returnButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let nextKeyboardButton = createSpecialButton(title: "🌐", action: #selector(handleInputModeList(from:with:)))
        nextKeyboardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        
        stackView.addArrangedSubview(symbolButton)
        stackView.addArrangedSubview(commaButton)
        stackView.addArrangedSubview(spaceButton)
        stackView.addArrangedSubview(dotButton)
        stackView.addArrangedSubview(returnButton)
        stackView.addArrangedSubview(nextKeyboardButton)
        
        return stackView
    }
    
    private func createKeyButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }
    
    private func createSpecialButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.systemGray3
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }
    
    @objc private func numberKeyPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        textDocumentProxy.insertText(title)
    }
    
    @objc private func letterKeyPressed(_ sender: UIButton) {
        // Don't insert text if popup is showing
        if popupView != nil {
            return
        }
        
        // Get the original lowercase letter from accessibilityIdentifier
        guard let lowercaseLetter = sender.accessibilityIdentifier else { return }
        
        let text: String
        if isShifted || isCapsLocked {
            text = lowercaseLetter.uppercased()
        } else {
            text = lowercaseLetter
        }
        
        textDocumentProxy.insertText(text)
        
        if isShifted && !isCapsLocked {
            isShifted = false
            updateShiftState()
        }
    }
    
    @objc private func shiftPressed() {
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastPress = currentTime - lastShiftPressTime
        
        // Double-tap detection (within 0.5 seconds)
        if timeSinceLastPress < 0.5 && isShifted && !isCapsLocked {
            // Enable caps lock
            isCapsLocked = true
            isShifted = false
        } else if isCapsLocked {
            // Disable caps lock
            isCapsLocked = false
            isShifted = false
        } else if isShifted {
            // Turn off shift
            isShifted = false
        } else {
            // Turn on shift
            isShifted = true
        }
        
        lastShiftPressTime = currentTime
        updateShiftState()
    }
    
    @objc private func deletePressed() {
        textDocumentProxy.deleteBackward()
    }
    
    @objc private func spacePressed() {
        textDocumentProxy.insertText(" ")
    }
    
    private func setupSpaceButtonGestures(_ button: UIButton) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(spaceSwipedLeft))
        leftSwipeGesture.direction = .left
        button.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(spaceSwipedRight))
        rightSwipeGesture.direction = .right
        button.addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc private func spaceSwipedLeft() {
        switchLanguage()
    }
    
    @objc private func spaceSwipedRight() {
        switchLanguage()
    }
    
    private func switchLanguage() {
        currentLanguage = (currentLanguage == .english) ? .russian : .english
        
        // Reset shift and caps lock when switching languages
        isShifted = false
        isCapsLocked = false
        
        // Update space button title to show current language
        updateSpaceButtonTitle()
        
        // Rebuild keyboard with new language
        setupKeyboard()
    }
    
    private func updateSpaceButtonTitle() {
        spaceButton?.setTitle("\(currentLanguage.displayName) space", for: .normal)
    }
    
    @objc private func returnPressed() {
        textDocumentProxy.insertText("\n")
    }
    
    @objc private func toggleSymbolsMode() {
        isSymbolsMode.toggle()
        isExtendedSymbolsMode = false // Reset extended symbols when switching modes
        setupKeyboard()
        updateAppearance()
    }
    
    @objc private func toggleExtendedSymbols() {
        isExtendedSymbolsMode.toggle()
        setupKeyboard()
        updateAppearance()
    }
    
    @objc private func symbolRowKeyPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        textDocumentProxy.insertText(title)
    }
    
    @objc private func punctuationKeyPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        textDocumentProxy.insertText(title)
    }
    
    @objc private func softSignLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        if gesture.state == .began {
            showSoftSignPopup(above: button)
        }
    }
    
    private func showSoftSignPopup(above button: UIButton) {
        hidePopup()
        
        // Always display uppercase in popup
        let option1 = "Ь"
        let option2 = "Ъ"
        
        let backdrop = UIView(frame: view.bounds)
        backdrop.backgroundColor = UIColor.clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        backdrop.addGestureRecognizer(tapGesture)
        
        let popupHeight: CGFloat = 60
        let buttonWidth: CGFloat = 60
        let totalWidth = buttonWidth * 2 + 10
        
        let popup = UIView()
        popup.backgroundColor = UIColor.white
        popup.layer.cornerRadius = 8
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOffset = CGSize(width: 0, height: 2)
        popup.layer.shadowOpacity = 0.3
        popup.layer.shadowRadius = 4
        
        let buttonFrame = button.convert(button.bounds, to: view)
        let popupX = buttonFrame.midX - totalWidth / 2
        let popupY = buttonFrame.minY - popupHeight - 10
        
        popup.frame = CGRect(x: popupX, y: popupY, width: totalWidth, height: popupHeight)
        
        let button1 = UIButton(type: .system)
        button1.setTitle(option1, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button1.setTitleColor(.black, for: .normal)
        button1.backgroundColor = .white
        button1.layer.cornerRadius = 5
        button1.frame = CGRect(x: 5, y: 10, width: buttonWidth, height: 40)
        button1.addTarget(self, action: #selector(softSignSelected(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setTitle(option2, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button2.setTitleColor(.black, for: .normal)
        button2.backgroundColor = UIColor.systemBlue
        button2.setTitleColor(.white, for: .normal)
        button2.layer.cornerRadius = 5
        button2.frame = CGRect(x: buttonWidth + 10, y: 10, width: buttonWidth, height: 40)
        button2.addTarget(self, action: #selector(hardSignSelected(_:)), for: .touchUpInside)
        
        popup.addSubview(button1)
        popup.addSubview(button2)
        
        view.addSubview(backdrop)
        backdrop.addSubview(popup)
        popupView = backdrop
    }
    
    private func hidePopup() {
        popupView?.removeFromSuperview()
        popupView = nil
    }
    
    @objc private func dismissPopup() {
        hidePopup()
    }
    
    @objc private func softSignSelected(_ sender: UIButton) {
        let shouldUppercase = isShifted || isCapsLocked
        textDocumentProxy.insertText(shouldUppercase ? "Ь" : "ь")
        hidePopup()
        
        if isShifted && !isCapsLocked {
            isShifted = false
            updateShiftState()
        }
    }
    
    @objc private func hardSignSelected(_ sender: UIButton) {
        let shouldUppercase = isShifted || isCapsLocked
        textDocumentProxy.insertText(shouldUppercase ? "Ъ" : "ъ")
        hidePopup()
        
        if isShifted && !isCapsLocked {
            isShifted = false
            updateShiftState()
        }
    }
    
    private func updateShiftState() {
        guard !isSymbolsMode else { return }
        setupKeyboard()
    }
    
    private func updateShiftButtonAppearance() {
        guard let button = shiftButton else { return }
        
        let isDarkMode = textDocumentProxy.keyboardAppearance == .dark
        
        if isShifted || isCapsLocked {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.systemBlue, for: .normal)
        } else {
            let specialKeyColor = isDarkMode ? UIColor.systemGray2 : UIColor.systemGray4
            let textColor = isDarkMode ? UIColor.white : UIColor.black
            button.backgroundColor = specialKeyColor
            button.setTitleColor(textColor, for: .normal)
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
        let backgroundColor = isDarkMode ? UIColor.black : UIColor.systemGray5
        let keyColor = isDarkMode ? UIColor.systemGray3 : UIColor.white
        let specialKeyColor = isDarkMode ? UIColor.systemGray2 : UIColor.systemGray4
        let textColor = isDarkMode ? UIColor.white : UIColor.black
        
        view.backgroundColor = backgroundColor
        
        updateColorsRecursively(in: view, keyColor: keyColor, specialKeyColor: specialKeyColor, textColor: textColor)
    }
    
    private func updateColorsRecursively(in view: UIView, keyColor: UIColor, specialKeyColor: UIColor, textColor: UIColor) {
        if let button = view as? UIButton {
            if let title = button.currentTitle {
                if title == "⇧" {
                    updateShiftButtonAppearance()
                } else if title == "⌫" || title == "🌐" || title.contains("space") || title == "return" || title == "↵" || title == "ABC" || title == "1/2" || title == "2/2" || title == "!#1" {
                    button.backgroundColor = specialKeyColor
                    button.setTitleColor(textColor, for: .normal)
                } else {
                    button.backgroundColor = keyColor
                    button.setTitleColor(textColor, for: .normal)
                }
            }
        }
        
        for subview in view.subviews {
            updateColorsRecursively(in: subview, keyColor: keyColor, specialKeyColor: specialKeyColor, textColor: textColor)
        }
    }
}
