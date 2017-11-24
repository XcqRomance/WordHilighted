//
//  BookCollectionViewController.swift
//  WordHilight
//
//  Created by romance on 16/8/29.
//  Copyright © 2016年 Romance. All rights reserved.
//

import UIKit
import AVFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


private let reuseIdentifier = "BookCollectionViewCell"

class BookCollectionViewController: UIViewController{

    var model : RootClass?
    var audioPlayer : AVAudioPlayer?
    @IBOutlet var collectionView: UICollectionView!
    var attributeStr:  NSMutableAttributedString?
    var wordRanges = [NSRange]()
    var displayLink : CADisplayLink?
    var delayBlock: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuColletionView()
        addSwipeGesture()
        jsonToModel()
        setupTimer()
        setupRightButton()
    }
    
    // MARK: - private method
    fileprivate func setupRightButton() {
        let btn = UIButton(type: .contactAdd)
        btn.addTarget(self, action: #selector(BookCollectionViewController.push), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func push() {
        let test = Test1ViewController()
        test.navigationItem.title = "测试"
        test.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(test, animated: true)
    }
    
    fileprivate func configuColletionView() {
        navigationItem.title = "单词高亮"
        let nib = UINib(nibName: "BookCollectionViewCell", bundle: nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.collectionViewLayout = TopicListLayout()
    }
    
    fileprivate func addSwipeGesture() {
        // 向右滑动
        let scrollGesture = UISwipeGestureRecognizer(target: self, action: #selector(BookCollectionViewController.handleSwipe(_:)))
        scrollGesture.direction = .right
        collectionView.addGestureRecognizer(scrollGesture)
        
        // 向左滑动
        let lscrollGesture = UISwipeGestureRecognizer(target: self, action: #selector(BookCollectionViewController.handleSwipe(_:)))
        lscrollGesture.direction = .left
        collectionView.addGestureRecognizer(lscrollGesture)
    }
    
    fileprivate func jsonToModel() {
        let lrcPath = Bundle.main.path(forResource: "lrc", ofType: "json")
        // 加载json文件
        let data = try? Data(contentsOf: URL(fileURLWithPath: lrcPath!))
        var dict = NSDictionary()
        // json转为dictionnary或者array
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            dict = jsonDict as! NSDictionary
        } catch {
            print(error)
        }
        
        model = RootClass(fromDictionary: dict)
    }
    
    fileprivate func setupTimer() {
        displayLink = CADisplayLink(target: self, selector: #selector(BookCollectionViewController.displayWord))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode) // mode 为 NSRunLoopCommonModes
        // 调用的频率 默认为值1，代表60Hz，即每秒刷新60次，调用每秒 displayWord() 60次，这里设置为10，代表6Hz
        displayLink?.frameInterval = 10
    }
    
    // MARK: - response method
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        cancel(delayBlock) // 取消延迟的2秒跳转，因为此时已经手动滑动了
        handleSwipeWithDirection(gesture.direction)
    }
    
    func handleSwipeWithDirection(_ dir: UISwipeGestureRecognizerDirection) {
        let cell = self.collectionView.visibleCells.first as! BookCollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        
        attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], range: NSMakeRange(0, attributeStr!.length))
        cell.content.attributedText = attributeStr

        if dir == .right {
            guard let index = (indexPath as NSIndexPath?)?.item , index > 0 else {return} // 处理第一个越界的问题
            collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
        } else if dir == .left {
            guard let index = (indexPath as NSIndexPath?)?.item , index < ((model?.pages.count ?? 1)-1)else {return} // 处理最后一个越界的问题
            collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func displayWord() {
        let cell = self.collectionView.visibleCells.first as! BookCollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        
        guard let page = model?.pages[((indexPath as NSIndexPath?)?.item)!] else {return}
        guard let section = page.sections.first else {return}
        var i = 0
        while true {
            let curTime = audioPlayer?.currentTime ?? 0 // 播放声音的的时间，ms
            
            guard (wordRanges.first != nil) else {break}
            
            let word = section.words[i]
            
            let curRange = wordRanges[i]
            if Int(curTime * 1000) >=  Int(word.cueStartMs) { // 拿当前播放的声音时间与json每个单词的开始读取时间相比，
                attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], range: NSMakeRange(0, attributeStr!.length))
                attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: curRange)
                cell.content.attributedText = attributeStr
            }
            
            i += 1
            
            if i >= wordRanges.count || i >= section.words.count {
                break
            }
        }
    }
    
    func playAudio() {
        audioPlayer?.play()
        displayLink?.isPaused = false
    }
    
    deinit {
        displayLink?.invalidate() // 此方法应该在惦记返回按钮的时候才调用，否则整个控制器都不会被销毁
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer?.delegate = nil
        displayLink?.isPaused = true
        audioPlayer?.stop()
//        displayLink?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playAudio()
    }
}


// MARK: - TopicListLayout
class TopicListLayout: UICollectionViewFlowLayout {
    override func prepare() {
        itemSize = CGSize(width: (collectionView?.frame.width)!, height: (collectionView?.frame.height)!)
        minimumLineSpacing = 0
        scrollDirection = .horizontal
    }
}

extension BookCollectionViewController: AVAudioPlayerDelegate,UICollectionViewDelegate, UICollectionViewDataSource  {
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        displayLink?.isPaused = true
        
        let cell = self.collectionView.visibleCells.first as! BookCollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        
        attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], range: NSMakeRange(0, attributeStr!.length))
        cell.content.attributedText = attributeStr
        weak var weakSelf = self
        let after = delay(2) { // 延迟2s才执行跳转
            guard let index = (indexPath as NSIndexPath?)?.item , index < ((weakSelf!.model?.pages.count ?? 1)-1)else {return} // 处理最后一个越界的问题
            weakSelf!.collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
        }
        delayBlock = after
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.pages.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        
        let page = model?.pages[(indexPath as NSIndexPath).item]
        let section = page!.sections.first
        cell.cover.image = UIImage(named: "p\((indexPath as NSIndexPath).item + 1).png")
        cell.content.text = section?.text
        
        let audioPath = Bundle.main.path(forResource: section?.audioFilename, ofType: nil)
        let audioURL = URL(string: audioPath!)
        audioPlayer = try! AVAudioPlayer(contentsOf: audioURL!)
        audioPlayer?.delegate = self
        
        playAudio()
        
        attributeStr = NSMutableAttributedString(string: section!.text)
        cell.content.attributedText = attributeStr
        let textStr: NSString = section!.text as NSString
        self.wordRanges.removeAll() // 在下一次添加之前，得先删除之前的
        weak var weakSelf = self
        textStr.enumerateSubstrings(in: NSMakeRange(0, textStr.length), options: .byWords) { (substring, substringRange, enclosingRange, bb) in
            weakSelf!.wordRanges.append(substringRange)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cancel(delayBlock)
        if ((audioPlayer?.isPlaying) == true) {
            audioPlayer?.pause()
        } else {
            playAudio()
        }
    }
    
}
