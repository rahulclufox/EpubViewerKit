//
//  ViewController.swift
//  EpubKittyExample
//
//  Created by 小发工作室 on 2020/3/26.
//  Copyright © 2020 小发工作室. All rights reserved.
//

import UIKit
import EpubViewerKit

class ViewController: UIViewController,FolioReaderPageDelegate{
    let folioReader = FolioReader()
    var config: EpubConfig?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIButton(frame: CGRect(x: 50, y: 150, width: 200, height: 40))
        button.setTitle("Open EPDF", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(openPDF), for: .touchUpInside)
        view.addSubview(button)
        
//        self.config = EpubConfig.init(Identifier: "Identifier",
//                                      tintColor: UIColor.green,
//                                      allowSharing: false,
//                                      scrollDirection: "horizontal")
//
//        //let readerVc = UIApplication.shared.keyWindow!.rootViewController ?? UIViewController()
//        let epubPath = Bundle.main.path(forResource: "kapalam", ofType: "epub") ?? ""
//        //print("##READER VC : \(readerVc)")
//        print("##EPUB PATH :\(epubPath)")
//        print("##SELF :\(self)")
//        
//        folioReader.presentReader(parentViewController: self, withEpubPath: epubPath, andConfig: self.config!.config, shouldRemoveEpub: true)
        print("##Loaded")
          
    }
    
    @objc func openPDF() {
        self.config = EpubConfig.init(Identifier: "Identifier",
                                      tintColor: UIColor.green,
                                      allowSharing: false,
                                      scrollDirection: "horizontal")

        //let readerVc = UIApplication.shared.keyWindow!.rootViewController ?? UIViewController()
        let epubPath = Bundle.main.path(forResource: "kapalam", ofType: "epub") ?? ""
        //print("##READER VC : \(readerVc)")
        print("##EPUB PATH :\(epubPath)")
        print("##SELF :\(self)")
        
        folioReader.presentReader(parentViewController: self, withEpubPath: epubPath, andConfig: self.config!.config, shouldRemoveEpub: true)
        folioReader.readerCenter?.pageDelegate = self
    }


    public func pageWillLoad(_ page: FolioReaderPage) {
        
        print("page.pageNumber:"+String(page.pageNumber))


    }
}

