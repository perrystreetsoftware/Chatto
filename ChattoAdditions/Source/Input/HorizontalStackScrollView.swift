/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

open class HorizontalStackScrollView: UIScrollView {

    enum ItemLayout {
        case leading
        case fill
    }

    private var arrangedViews: [UIView] = []
    private let arrangedViewsHolderView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    var interItemSpacing: CGFloat = 0.0 {
        didSet {
            arrangedViewsHolderView.spacing = interItemSpacing
        }
    }

    var itemLayout: ItemLayout = .leading {
        didSet {
            switch itemLayout {
            case .leading:
                arrangedViewsHolderView.distribution = .fill
                pinWidthOfStackViewToParentScrollViewConstraint.isActive = false
            case .fill:
                arrangedViewsHolderView.distribution = .fillEqually
                pinWidthOfStackViewToParentScrollViewConstraint.isActive = true
            }
        }
    }

    private var pinWidthOfStackViewToParentScrollViewConstraint: NSLayoutConstraint!

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        layoutStackView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutStackView()
    }

    private func layoutStackView() {
        addSubview(arrangedViewsHolderView)
        arrangedViewsHolderView.translatesAutoresizingMaskIntoConstraints = false
        arrangedViewsHolderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        arrangedViewsHolderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        arrangedViewsHolderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        arrangedViewsHolderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pinWidthOfStackViewToParentScrollViewConstraint = arrangedViewsHolderView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor)
        arrangedViewsHolderView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }

    func addArrangedViews(_ views: [UIView]) {
        for view in views {
            arrangedViewsHolderView.addArrangedSubview(view)
        }
        self.arrangedViews.append(contentsOf: views)
    }
}
