//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import AVKit

fileprivate extension CGFloat {
    static let miniAudioPlayerOffsetFromBottom: CGFloat = 8
}

@IBDesignable
class ResourcesVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cruSegmentedControl: CruSegmentedControl!
    @IBOutlet weak var fakeBottomOfNavBarView: UIView!
    
    private var shadowImageView: UIImageView?
    private var collectionViewCellLayout: [ResourceType] = [.article, .video, .audio]
    private var audioController: CruAudioControl = UINib(nibName: String(describing: CruAudioControl.self), bundle: nil).instantiate(withOwner: self, options: nil)[0] as! CruAudioControl
    private var miniAudioPlayerPositionConstraint : NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insertProfileButtonInNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.popToRootViewController), name: MainTabBarController.tabBarChangedNotification, object: nil)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerCell(ResourcesTableViewCollectionViewCell.self)
        self.fakeBottomOfNavBarView.addBorders(edges: .bottom, color: .navBarLineGray, thickness: 0.5)
        
        self.view.addSubview(self.audioController)
        self.audioController.translatesAutoresizingMaskIntoConstraints = false
        let miniAudioPlayerPositionConstraint = self.audioController.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        NSLayoutConstraint.activate([
            self.audioController.leftAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leftAnchor),
            self.audioController.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor),
            miniAudioPlayerPositionConstraint
        ])
        self.miniAudioPlayerPositionConstraint = miniAudioPlayerPositionConstraint
        
        self.audioController.audioResourceDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shadowImageView == nil {
            self.shadowImageView = self.findShadowImage(under: self.navigationController!.navigationBar)
        }
        self.shadowImageView?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shadowImageView?.isHidden = false
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as? UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = self.findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
    @IBAction func valueDidChange(_ sender: CruSegmentedControl) {
        self.collectionView.scrollToItem(at: IndexPath(item: sender.selectedSegmentIndex, section: 0), at: .left, animated: true)
    }
}

extension ResourcesVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ResourcesTableViewCollectionViewCell.self, indexPath: indexPath)
        cell.resourcePresentingDelegate = self
        cell.type = self.collectionViewCellLayout[indexPath.item]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.cruSegmentedControl.updateSelectorPosition(offset: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.collectionView.frame.width)
        self.cruSegmentedControl.selectedSegmentIndex = index
    }
}

extension ResourcesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension ResourcesVC: ResourcePresentingDelegate {
    func presentResource(of type: ResourceType, resource: Resource) {
        switch type {
        case .audio:
            let vc = UIStoryboard(name: "Resources", bundle: nil).instantiateViewController(AudioResourceDetailVC.self)
            vc.resource = resource
            vc.audioResourceDelegate = self
            self.show(vc, sender: self)
        case .video:
            let vc = UIStoryboard(name: "Resources", bundle: nil).instantiateViewController(VideoResourceDetailVC.self)
            vc.resource = resource
            self.show(vc, sender: self)
        case .article:
            let vc = UIStoryboard(name: "Resources", bundle: nil).instantiateViewController(ArticleResourceDetailVC.self)
            vc.resource = resource
            self.show(vc, sender: self)
        }
    }
}

extension ResourcesVC: AudioResourceDelegate {
    func playAudioFromURL(url: URL, title: String) {
        self.audioController.playAudioFromURL(url: url)
        self.audioController.titleLabel.text = title
        self.revealMiniAudioPlayer()
    }
    
    func dismissMiniAudioPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.miniAudioPlayerPositionConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func revealMiniAudioPlayer() {
        UIView.animate(withDuration: 0.3) {
            self.miniAudioPlayerPositionConstraint?.constant = -(self.audioController.bounds.height + .miniAudioPlayerOffsetFromBottom)
            self.view.layoutIfNeeded()
        }
    }
    
    func showAVPlayerViewController(player: AVPlayer) {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.addObserver(self.audioController, forKeyPath: #keyPath(AVPlayerViewController.view.frame), options: [], context: nil)
        self.present(vc, animated: true, completion: nil)
    }
}

protocol AudioResourceDelegate {
    func playAudioFromURL(url: URL, title: String)
    func dismissMiniAudioPlayer()
    func revealMiniAudioPlayer()
    func showAVPlayerViewController(player: AVPlayer)
}

protocol ResourcePresentingDelegate {
    func presentResource(of type: ResourceType, resource: Resource)
}
