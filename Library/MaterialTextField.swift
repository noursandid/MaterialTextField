//
//  MaterialTextField.swift
//  MaterialTextField
//
//  Created by Nour Sandid on 6/23/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

open class MaterialTextField: UITextField {
    enum State {
        case down
        case up
    }
    
    public var selectedColor: UIColor? { didSet { reloadStyle() }}
    public var unselectedColor: UIColor? { didSet { reloadStyle() }}
    public var textPadding: CGFloat = 8
    public var placeholderPadding: CGFloat = 0
    public override var placeholder: String? {
        set {
            self.placeholderLabel.text = newValue
        }
        get {
            self.placeholderLabel.text
        }
    }
    public override var text: String? {
        didSet {
            self.moveDownPlaceholder()
        }
    }
    override open var textAlignment: NSTextAlignment {
        didSet {
            if textAlignment == .right {
                semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    private var placeholderLabel: UILabel = UILabel()
    private var bottomLabel: UILabel = UILabel()
    private var bottomAttribute: (String?, UIColor?)?
    private var placeholderState: State = .up
    private let borderLayer = CALayer()
    private lazy var releasedConstraints = [
        self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                       constant: self.placeholderPadding),
        self.placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ]
    private lazy var selectedConstraints = [
        self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.placeholderPadding-8),
        self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor)
    ]
    
    
    public override func drawPlaceholder(in rect: CGRect) {}
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + self.textPadding,
            y: bounds.origin.y + self.textPadding,
            width: bounds.size.width - self.textPadding * 2,
            height: bounds.size.height - self.textPadding * 2
        )
    }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.drawBorder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.moveDownPlaceholder(false)
        self.addBottomLabel()
        
        self.layer.addSublayer(self.borderLayer)
        self.drawBorder()
        self.font = .systemFont(ofSize: 16)
    }
    
    func reloadStyle() {
        if self.placeholderState == .down {
            self.placeholderLabel.textColor = self.unselectedColor
            self.borderLayer.backgroundColor = self.unselectedColor?.cgColor
        } else {
            self.placeholderLabel.textColor = self.selectedColor
            self.borderLayer.backgroundColor = self.selectedColor?.cgColor
        }
    }
    
    private func addBottomLabel() {
        self.addSubview(self.bottomLabel)
        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            self.bottomLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        layoutIfNeeded()
    }
    
    private func drawBorder() {
        self.borderStyle = UITextField.BorderStyle.none
        var yValue = self.bounds.height - 1
        if self.bottomLabel.text?.isEmpty ?? true {
            yValue -= self.bottomLabel.frame.height - 2
        }
        self.borderLayer.frame = CGRect(x: 0, y: yValue,
                                        width: self.bounds.width, height: 1)
        
    }
    
    private func moveDownPlaceholder(_ animated: Bool = true) {
        if self.text?.isEmpty ?? true {
            if self.placeholderState != State.down {
                NSLayoutConstraint.deactivate(self.selectedConstraints)
                NSLayoutConstraint.activate(self.releasedConstraints)
                if animated {
                    UIView.animate(withDuration: 0.2) {
                        self.layoutIfNeeded()
                        self.placeholderLabel.transform = CGAffineTransform.identity
                    }
                } else {
                    self.layoutIfNeeded()
                }
                self.placeholderState = State.down
                self.placeholderLabel.textColor = self.unselectedColor
                self.borderLayer.backgroundColor = self.unselectedColor?.cgColor
            }
        } else {
            self.moveUpPlaceholder(animated)
        }
    }
    
    private func moveUpPlaceholder(_ animated: Bool = true) {
        if self.placeholderState != State.up {
            NSLayoutConstraint.deactivate(self.releasedConstraints)
            NSLayoutConstraint.activate(self.selectedConstraints)
            if animated {
                UIView.animate(withDuration: 0.2) {
                    self.layoutIfNeeded()
                    self.placeholderLabel.transform =
                        CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            } else {
                self.layoutIfNeeded()
            }
            self.placeholderState = State.up
            self.placeholderLabel.textColor = self.selectedColor
            self.borderLayer.backgroundColor = self.selectedColor?.cgColor
        }
    }
    public override func becomeFirstResponder() -> Bool {
        self.moveUpPlaceholder()
        return super.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        self.moveDownPlaceholder()
        return super.resignFirstResponder()
    }
    
    public func setError(_ error: String?) {
        self.bottomAttribute = error != nil ? (error, .red) : nil
        self.bottomLabel.textColor = self.bottomAttribute?.1
        self.bottomLabel.text = self.bottomAttribute?.0
        self.layoutIfNeeded()
    }
    
    public func setHint(_ hint: String?) {
        self.bottomAttribute = hint != nil ? (hint, self.selectedColor) : nil
        self.bottomLabel.textColor = self.bottomAttribute?.1
        self.bottomLabel.text = self.bottomAttribute?.0
        self.layoutIfNeeded()
    }
    
}
