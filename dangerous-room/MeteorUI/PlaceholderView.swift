// Copyright (c) 2014-2015 Martijn Walraven
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class PlaceholderView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  convenience init() {
    self.init(frame: CGRect.zero)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setUp()
  }
  
  private var loadingIndicatorView: UIActivityIndicatorView!
  private var contentView: UIView!
  private var titleLabel: UILabel!
  private var messageLabel: UILabel!
  
  func setUp() {
    let textColor = UIColor(white: 172/255.0, alpha:1)
    
    translatesAutoresizingMaskIntoConstraints = false
    
    loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicatorView.color = UIColor.lightGray
    addSubview(loadingIndicatorView)
    
    contentView = UIView(frame: CGRect.zero)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentView)
    
    titleLabel = UILabel(frame: CGRect.zero)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.textAlignment = .center
    titleLabel.backgroundColor = nil
    titleLabel.isOpaque = false
    titleLabel.font = UIFont.systemFont(ofSize: 22)
    titleLabel.numberOfLines = 0_
    titleLabel.textColor = textColor
    contentView.addSubview(titleLabel)
    
    messageLabel = UILabel(frame: CGRect.zero)
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.textAlignment = .center
    messageLabel.backgroundColor = nil
    messageLabel.isOpaque = false
    messageLabel.font = UIFont.systemFont(ofSize: 14)
    messageLabel.numberOfLines = 0_
    messageLabel.textColor = textColor
    contentView.addSubview(messageLabel)
    
    addConstraint(NSLayoutConstraint(item: loadingIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    addConstraint(NSLayoutConstraint(item: loadingIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    
    addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    
    let views = ["contentView": contentView, "titleLabel": titleLabel, "messageLabel": messageLabel]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=30)-[contentView(<=418)]-(>=30)-|", options: [], metrics: nil, views: views))
    } else {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[contentView]-30-|", options: [], metrics: nil, views: views))
    }
    
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: views))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageLabel]|", options: [], metrics: nil, views: views))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]-15-[messageLabel]|", options: [], metrics: nil, views: views))
  }
  
  private var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  private var message: String? {
    didSet {
      messageLabel.text = message
    }
  }
  
  func showLoadingIndicator() {
    contentView.isHidden = true
    loadingIndicatorView.startAnimating()
  }
  
  func hideLoadingIndicator() {
    contentView.isHidden = false
    loadingIndicatorView.stopAnimating()
  }
  
  func showTitle(title: String?, message: String?) {
    hideLoadingIndicator()
    self.title = title
    self.message = message
  }
}
