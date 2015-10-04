//
//  Filter.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import CoreImage

typealias Filter = CIImage -> CIImage

func blurWithRadius(radius: CGFloat) -> Filter {

    return { image in

        let parameters = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image,
        ]

        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters)

        return filter!.outputImage!
    }
}

func colorGenerator(color: UIColor) -> Filter {

    return { _ in

        let parameters = [
            kCIInputColorKey: CIColor(color: color),
        ]

        let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters)

        return filter!.outputImage!
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay,
        ]

        let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters)

        let cropRect = image.extent

        return filter!.outputImage!.imageByCroppingToRect(cropRect)
    }
}

func overlayWithColor(color: UIColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay)(image)
    }
}

infix operator +++ { associativity left }

func +++(filterA: Filter, filterB: Filter) -> Filter {
    return { image in
        return filterB(filterA(image))
    }
}

