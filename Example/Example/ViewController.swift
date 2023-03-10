//
// Copyright (c) 2022 Snapscreen Application GmbH <https://snapscreen.com>
//

import UIKit
import SnapscreenFramework
import ClipShareFramework
import SDWebImage

class ViewController: UIViewController {

    @IBAction func snapAndShareClip(_ sender: Any) {
        let snapViewController = SnapViewController.forSportsOperator(configuration: SnapConfiguration(), snapDelegate: self)
        snapViewController.isModalInPresentation = true
        snapViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSnap))
        self.present(UINavigationController(rootViewController: snapViewController), animated: true, completion: nil)
    }
    
    @objc private func cancelSnap() {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: SnapscreenSnapDelegate {
    
    func snapscreenSnapViewController(_ viewController: SnapViewController, didSnapSportEvent sportEvent: SportEventSnapResultEntry) {
        guard let tvChannelId = sportEvent.tvChannel?.id,
              let snapTimestamp = sportEvent.timestamp,
              let authorizationHeader = Snapscreen.instance?.authorizationHeader
        else { return }
        
        let epgUnitNameFallback =
            sportEvent.sportEvent?.league
            ?? sportEvent.sportEvent?.tournament
            ?? sportEvent.sportEvent?.sport
        let clipShareViewController = ClipShareViewController.forSportEventSnapResultOn(
            tvChannelId: tvChannelId,
            tvChannelLogoURL: sportEvent.tvChannel?.logoURL,
            tvChannelName: sportEvent.tvChannel?.name,
            epgUnitNameFallback: epgUnitNameFallback,
            snapTimestamp: snapTimestamp,
            snapscreenAuthorizationHeader: authorizationHeader,
            clipShareDelegate: self
        )
        viewController.navigationController?.pushViewController(clipShareViewController, animated: true)
    }
    
}

extension ViewController: ClipShareDelegate {
    
    func clipShareViewControllerDidFailCreatingClip(_ viewController: ClipShareViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Failed creating Clip", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func clipShareViewControllerDidFailLoadingClip(_ viewController: ClipShareViewController) {
        
    }
    
    func clipShareViewController(_ viewController: ClipShareViewController, didCreateClip clip: Clip) {
        viewController.dismiss(animated: true) { [weak self] in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Created Clip", message: "Successfully created clip", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Copy Clip Video URL", style: .default, handler: { _ in
                    UIPasteboard.general.url = clip.videoURL
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func clipShareShouldPrefetchURLs(_ imageURLs: [URL]) -> AnyObject? {
        return SDWebImagePrefetcher.shared.prefetchURLs(imageURLs)
    }
    
    func clipShareShouldCancelImageLoadingIn(imageView: UIImageView) {
        imageView.sd_cancelCurrentImageLoad()
    }
    
    func clipShareShouldLoadImageFrom(url: URL, intoImageView imageView: UIImageView, completion: ((Bool) -> Void)?) {
        let sdWebImageOptions: SDWebImageOptions = [.queryMemoryData, .queryMemoryDataSync]
        imageView.sd_setImage(with: url, placeholderImage: nil, options: sdWebImageOptions) { image, _, _, _ in
            completion?(image != nil)
        }
    }
}

