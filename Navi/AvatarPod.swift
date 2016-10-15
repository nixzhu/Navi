//
//  AvatarPod.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

final public class AvatarPod {

    private static let sharedInstance = AvatarPod()

    private let cache = NSCache<NSString, UIImage>()

    private lazy var session = URLSession(configuration: URLSessionConfiguration.default)

    public enum CacheType {
        case memory
        case disk
        case cloud
    }

    public typealias Completion = (_ finished: Bool, _ image: UIImage, _ cacheType: CacheType) -> Void

    private struct Request {

        let avatar: Avatar
        let completion: Completion

        var url: URL? {
            return avatar.url
        }

        var key: String {
            return avatar.key
        }
    }

    private class RequestTank {

        let url: URL
        var requests: [Request] = []

        init(url: URL) {
            self.url = url
        }
    }

    private class RequestPool {

        fileprivate var requestTanks = [URL: RequestTank]()

        func addRequest(_ request: Request) {

            guard let url = request.url else {
                return
            }

            if let requestTank = requestTanks[url] {
                requestTank.requests.append(request)

            } else {
                let requestTank = RequestTank(url: url)
                requestTanks[url] = requestTank
                requestTank.requests.append(request)
            }
        }

        func requestsWithURL(_ URL: Foundation.URL) -> [Request] {

            guard let requestTank = requestTanks[URL] else {
                return []
            }

            return requestTank.requests
        }

        func removeRequestsWithURL(_ URL: Foundation.URL) {

            requestTanks.removeValue(forKey: URL)
        }

        func removeAllRequests() {
            requestTanks.removeAll()
        }
    }

    private var requestPool = RequestPool()

    private let requestQueue = DispatchQueue(label: "com.nixWork.Navi.requestQueue", attributes: [])
    private let cacheQueue = DispatchQueue.global(qos: .background)

    private func completeRequest(_ request: Request, withStyledImage styledImage: UIImage, cacheType: CacheType) {

        DispatchQueue.main.async {
            request.completion(true, styledImage, cacheType)
        }

        cache.setObject(styledImage, forKey: request.key as NSString)
    }

    private func completeRequestsWithURL(_ URL: Foundation.URL, image: UIImage, cacheType: CacheType) {

        requestQueue.async {

            let requests = self.requestPool.requestsWithURL(URL)

            self.cacheQueue.async {

                requests.forEach({ request in

                    // if can find styledImage in cache, no need to generate it again or save

                    if let styledImage = self.cache.object(forKey: request.key as NSString) {
                        self.completeRequest(request, withStyledImage: styledImage, cacheType: cacheType)

                    } else {
                        let styledImage = image.navi_avatarImageWithStyle(request.avatar.style)

                        self.completeRequest(request, withStyledImage: styledImage, cacheType: cacheType)

                        // save images to local

                        request.avatar.save(originalImage: image, styledImage: styledImage)
                    }
                })
            }

            self.requestPool.removeRequestsWithURL(URL)
        }
    }

    // MARK: - API

    public class func wakeAvatar(_ avatar: Avatar, completion: @escaping Completion) {

        guard let url = avatar.url else {
            completion(false, avatar.placeholderImage ?? UIImage(), .memory)
            return
        }

        let request = Request(avatar: avatar, completion: completion)

        if let image = sharedInstance.cache.object(forKey: request.key as NSString) {
            completion(true, image, .memory)

        } else {
            if let placeholderImage = avatar.placeholderImage {
                completion(false, placeholderImage, .memory)
            }

            sharedInstance.cacheQueue.async {

                if let styledImage = avatar.localStyledImage {
                    sharedInstance.completeRequest(request, withStyledImage: styledImage, cacheType: .disk)

                } else {
                    sharedInstance.requestQueue.async {

                        sharedInstance.requestPool.addRequest(request)

                        if sharedInstance.requestPool.requestsWithURL(url).count > 1 {
                            // do nothing

                        } else {
                            sharedInstance.cacheQueue.async {

                                if let image = avatar.localOriginalImage {
                                    sharedInstance.completeRequestsWithURL(url, image: image, cacheType: .disk)

                                } else {
                                    let task = sharedInstance.session.dataTask(with: url, completionHandler: { data, response, error in

                                        guard error == nil, let data = data, let image = UIImage(data: data) else {
                                            sharedInstance.requestQueue.async {
                                                sharedInstance.requestPool.removeRequestsWithURL(url)
                                            }

                                            return
                                        }

                                        sharedInstance.completeRequestsWithURL(url, image: image, cacheType: .cloud)
                                    }) 
                                    
                                    task.resume()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public class func clear() {
        
        sharedInstance.requestPool.removeAllRequests()
        
        sharedInstance.cache.removeAllObjects()
    }
}

