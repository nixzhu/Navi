//
//  Filter.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import CoreImage

typealias Filter = (CIImage) -> CIImage

func blurWithRadius(_ radius: CGFloat) -> Filter {

    return { image in

        let parameters = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image,
        ] as [String : Any]

        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters)

        return filter!.outputImage!
    }
}

func colorGenerator(_ color: UIColor) -> Filter {

    return { _ in

        let parameters = [
            kCIInputColorKey: CIColor(color: color),
        ]

        let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters)

        return filter!.outputImage!
    }
}

func compositeSourceOver(_ overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay,
        ]

        let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters)

        let cropRect = image.extent

        return filter!.outputImage!.cropped(to: cropRect)
    }
}

func overlayWithColor(_ color: UIColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay)(image)
    }
}

precedencegroup FilterPrecedence {
    associativity: left
}

infix operator +++: FilterPrecedence

func +++(filterA: @escaping Filter, filterB: @escaping Filter) -> Filter {
    return { image in
        return filterB(filterA(image))
    }
}

