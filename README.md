<p>
<a href="http://cocoadocs.org/docsets/Navi"><img src="https://img.shields.io/cocoapods/v/Navi.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

# Navi

Navi is designed for avatar caching, with style.

The name of **Navi** from movie [Avatar](https://en.wikipedia.org/wiki/Avatar_(2009_film)).

## Requirements

Swift 3.1, iOS 8.0

- Swift 2.3, use version 0.5.0
- Swift 3.0, use version 1.1.0

## Usage

1. Make your User conform Avatar protocol.

	``` swift
	protocol Avatar {

	    var url: URL? { get }
	    var style: AvatarStyle { get }
	    var placeholderImage: UIImage? { get }
	    var localOriginalImage: UIImage? { get }
	    var localStyledImage: UIImage? { get }

	    func save(originalImage: UIImage, styledImage: UIImage)
	}
	```

2. And, set avatar for your avatarImageView

	``` swift
	avatarImageView.navi_setAvatar(userAvatar)
	```

Check the demo for more information.

另有[中文介绍](https://github.com/nixzhu/dev-blog/blob/master/2015-10-08-navi.md)。

## Installation

### Carthage

```ogdl
github "nixzhu/Navi"
```

### CocoaPods

```ruby
pod 'Navi'
```

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

Navi is available under the MIT license. See the LICENSE file for more info.
