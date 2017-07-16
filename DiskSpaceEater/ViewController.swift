//
//  ViewController.swift
//  DiskSpaceEater
//
//  Created by Shinichiro Oba on 2017/07/16.
//  Copyright © 2017 Shinichiro Oba. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var freeSizeLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var fileSizeTextField: UITextField!
    @IBOutlet weak var numberOfFilesTextField: UITextField!
    
    let targetUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var eater: DiskSpaceEater {
        return DiskSpaceEater(targetUrl: targetUrl)
    }
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    func string(fileSize: Int64?) -> String? {
        return fileSize
            .flatMap { NSNumber(value: $0) }
            .flatMap { numberFormatter.string(from: $0) }
            .flatMap { $0 + " byte" }
    }
    
    func string(percentage: Double?) -> String? {
        return percentage
            .flatMap { String(format: "%0.1f %%", $0) }
    }
    
    func updateLabels() {
        let info = FileSystemInfo(url: targetUrl)
        freeSizeLabel.text = string(fileSize: info?.systemFreeSize) ?? "-"
        sizeLabel.text = string(fileSize: info?.systemSize) ?? "-"
        percentageLabel.text = string(percentage: info?.freeSpace) ?? "-"
    }
    
    func show(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func createEmptyFiles() {
        guard let fileSize = fileSizeTextField.text.flatMap({ Int($0) }), fileSize > 0,
            let num = numberOfFilesTextField.text.flatMap({ Int($0) }), num > 0 else {
                return
        }
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            do {
                try self?.eater.createEmptyFiles(fileSize: fileSize, num: num)
                self?.show(message: "Created \(num) files")
            } catch (let error) {
                self?.show(message: "Error: \(error)")
            }
        }
    }
    
    func deleteAllFiles() {
        do {
            let num = try self.eater.deleteAllFiles()
            show(message: "Deleted \(num) files")
        } catch (let error) {
            show(message: "Error: \(error)")
        }
    }
    
    @IBAction func createButtonPushed(_ sender: Any) {
        createEmptyFiles()
    }
    
    @IBAction func deleteButtonPushed(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Delete All File?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.deleteAllFiles()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateLabels()
        }
    }
}
