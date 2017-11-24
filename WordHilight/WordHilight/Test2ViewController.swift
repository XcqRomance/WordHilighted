//
//  ViewController.swift
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


class Test2ViewController: UIViewController {

    @IBOutlet weak var wordLabel: UILabel!
    var model : RootClass?
    var displayLink : CADisplayLink?
    var i = 0
    var audioPlayer : AVAudioPlayer?
    var textDict = [String: NSRange]()
    var attributeStr:  NSMutableAttributedString?
    var wordRanges = [NSRange]()//[Range<String.Index>]()
    var wordRange: Range<String.Index>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        jsonToModel()
        
        
         
//        guard let audioPath = NSBundle.mainBundle().pathForResource("raz_hugs_le02_p3_text.mp3", ofType: nil) else {return}
//        let audioURL = NSURL(string: audioPath)
//        
//        audioPlayer = try! AVAudioPlayer(contentsOfURL: audioURL!)
//        audioPlayer?.delegate = self
//        
//        audioPlayer?.play()
////        print("\(audioPlayer?.currentTime)")
//        
//        guard let page = model?.pages.first else {return}
//        guard let section = page.sections.first else {return}
//        
//        attributeStr = NSMutableAttributedString(string: section.text)
//        wordLabel.attributedText = attributeStr
//        
//        let textStr: NSString = section.text
//        
//        textStr.enumerateSubstringsInRange(NSMakeRange(0, textStr.length), options: .ByWords) { (substring, substringRange, enclosingRange, bb) in
////            self.textDict[substring!] = substringRange
//            self.wordRanges.append(substringRange)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupTimer()
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
    
    func setupTimer() {
        displayLink = CADisplayLink(target: self, selector: #selector(Test2ViewController.displayWord))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes) // mode 为 NSRunLoopCommonModes
         // 调用的频率 默认为值1，代表60Hz，即每秒刷新60次，调用每秒 displayWord() 60次，这里设置为10，代表10Hz
        displayLink?.frameInterval = 10
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        displayLink?.invalidate()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func displayWord() {
//        print("\(i)-\(NSDate(timeIntervalSinceNow: 0))")
//        i += 1
        
        guard let page = model?.pages.first else {return}
        guard let section = page.sections.first else {return}
        var i = 0
        while true {
            let curTime = audioPlayer?.currentTime ?? 0 // 播放声音的的时间，ms
            let word = section.words[i]
            
            let curRange = wordRanges[i]
            if Int(curTime * 1000) >=  Int(word.cueStartMs) { // 拿当前播放的声音时间与json每个单词的开始读取时间相比，
                attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], range: NSMakeRange(0, attributeStr!.length))
                attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: curRange)
                wordLabel.attributedText = attributeStr
            }
            
            i += 1
            if i >= wordRanges.count {
                break
            }
        }
    }
    
    deinit {
        print("Test2ViewController-deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.isPaused = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayLink?.isPaused = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
      print("\(String(describing: audioPlayer?.currentTime))")
    }
}

extension Test2ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        print("\(player.currentTime)")
        displayLink?.isPaused = true
        
        attributeStr?.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], range: NSMakeRange(0, attributeStr!.length))
        wordLabel.attributedText = attributeStr
    }
    
}

