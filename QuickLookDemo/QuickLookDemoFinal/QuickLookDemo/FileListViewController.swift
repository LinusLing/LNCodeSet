//
//  FileListViewController.swift
//  QuickLookDemo
//
//  Created by Gabriel Theodoropoulos on 3/28/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit
import QuickLook

class FileListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    @IBOutlet weak var tblFileList: UITableView!
    
    let fileNames = ["AppCoda-PDF.pdf", "AppCoda-Pages.pages", "AppCoda-Word.docx", "AppCoda-Keynote.key", "AppCoda-Text.txt", "AppCoda-Image.jpeg"]
    
    var fileURLs = [NSURL]()
    
    let quickLookController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFileURLs()
        quickLookController.dataSource = self
        quickLookController.delegate = self
        configureTableView()
        navigationItem.title = "Quick Look Demo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareFileURLs() {
        for file in fileNames {
            let fileParts = file.componentsSeparatedByString(".")
            if let fileURL = NSBundle.mainBundle().URLForResource(fileParts[0], withExtension: fileParts[1]) {
                if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
                    fileURLs.append(fileURL)
                }
            }
        }
    }
    
    func extractAndBreakFilenameInComponents(fileURL: NSURL) -> (fileName: String, fileExtension: String) {
        
        // 将 NSURL 路径分割成零组件，然后创建一个数组将其放置其中
        let fileURLParts = fileURL.path!.componentsSeparatedByString("/")
        
        // 从上面数组的最后一个元素中得到文件名
        let fileName = fileURLParts.last
        
        // 将文件名基于符号 . 分割成不同的零组件，并放置在数组中返回
        let filenameParts = fileName?.componentsSeparatedByString(".")
        
        // 返回最终的元组
        return (filenameParts![0], filenameParts![1])
    }
    

    // MARK: Custom Methods
    
    func configureTableView() {
        tblFileList.delegate = self
        tblFileList.dataSource = self
        tblFileList.registerNib(UINib(nibName: "FileListCell", bundle: nil), forCellReuseIdentifier: "idCellFile")
        tblFileList.reloadData()
    }
    
    func getFileTypeFromFileExtension(fileExtension: String) -> String {
        var fileType = ""
        
        switch fileExtension {
        case "docx":
            fileType = "Microsoft Word document"
            
        case "pages":
            fileType = "Pages document"
            
        case "jpeg":
            fileType = "Image document"
            
        case "key":
            fileType = "Keynote document"
            
        case "pdf":
            fileType = "PDF document"
            
            
        default:
            fileType = "Text document"
            
        }
        
        return fileType
    }

    
    // MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileURLs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellFile", forIndexPath: indexPath)
        
        let currentFileParts = extractAndBreakFilenameInComponents(fileURLs[indexPath.row])
        
        cell.textLabel?.text = currentFileParts.fileName
        
        cell.detailTextLabel?.text = getFileTypeFromFileExtension(currentFileParts.fileExtension)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    // MARK: QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if QLPreviewController.canPreviewItem(fileURLs[indexPath.row]) {
            quickLookController.currentPreviewItemIndex = indexPath.row
            navigationController?.pushViewController(quickLookController, animated: true)
            //presentViewController(quickLookController, animated: true, completion: nil)
        }    
    }
    
    // MARK: QLPreviewControllerDelegate
    
    func previewControllerWillDismiss(controller: QLPreviewController) {
        print("The Preview Controller will be dismissed.")
    }
    
    func previewControllerDidDismiss(controller: QLPreviewController) {
        tblFileList.deselectRowAtIndexPath(tblFileList.indexPathForSelectedRow!, animated: true)
        print("The Preview Controller has been dismissed.")
    }
    
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        if item as! NSURL == fileURLs[0] {
            return true
        }
        else {
            print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
    
}
