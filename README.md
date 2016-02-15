<p>
<a href="http://cocoadocs.org/docsets/Navi"><img src="https://img.shields.io/cocoapods/v/Navi.svg?style=flat"></a> 
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a> 
</p>

# Navi

Navi is designed for avatar caching, with style. 

The name of **Navi** from movie [Avatar](https://en.wikipedia.org/wiki/Avatar_(2009_film)).

## Requirements

Swift 2.0, iOS 8.0

## Usage

1. Make your User conform Avatar protocol.

	``` swift
	protocol Avatar {

	    var URL: NSURL? { get }
	    var style: AvatarStyle { get }
	    var placeholderImage: UIImage? { get }
	    var localOriginalImage: UIImage? { get }
	    var localStyledImage: UIImage? { get }

	    func saveOriginalImage(originalImage: UIImage, styledImage: UIImage)
	}
	```

2. And, set avatar for your avatarImageView

	``` swift
	avatarImageView.navi_setAvatar(userAvatar)
	```

Check the demo for more information.

另有[中文介绍](https://github.com/nixzhu/dev-blog/blob/master/2015-10-08-navi.md)。

## Installation

### CocoaPods

```ruby
pod 'Navi', '~> 0.4.2'
```

### Carthage

```ogdl
github "nixzhu/Navi" >= 0.4.2
```

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

Navi is available under the MIT license. See the LICENSE file for more info.
