//
//  ViewController.swift
//  Bluetooth
//
//  Created by Marcelo De Souza on 2016-08-25.
//  Copyright © 2016 Marcelo de Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var connectionStatus: UILabel!
	@IBOutlet weak var sendDataButton: UIButton!
	@IBOutlet weak var console: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Watch Bluetooth connection
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(connectionChanged(_:)), name: BLEServiceChangedStatusNotification, object: nil)
		// Start the Bluetooth discovery process
		btDiscoverySharedInstance
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
	}

	func connectionChanged(notification: NSNotification) {
		// Connection status changed. Indicate on GUI.
		let userInfo = notification.userInfo as! [String: Bool]
		dispatch_async(dispatch_get_main_queue(), {
			// Set image based on connection status
			if let isConnected: Bool = userInfo["isConnected"] {
				if isConnected {
					self.connectionStatus.text = "Connection Status: Connected"
				} else {
					self.connectionStatus.text = "Connection Status: Disconnected"
				}
			}
		});
	}

	// MARK: Actions

	@IBAction func sendDataAction(sender: UIButton) {
		showAlert()
	}

	// MARK: Methods

	private func showAlert() {
		let alert = UIAlertController(title: "Message", message: "Write whatever you want to send to the device", preferredStyle: .Alert)
		var keyTextfield: UITextField!
		alert.addTextFieldWithConfigurationHandler { (textfield) in
			textfield.placeholder = "Text"
			keyTextfield = textfield
		}
		let confirm = UIAlertAction(title: "Send", style: .Default) { [weak self](action) in
			guard let text = keyTextfield.text else { return }
			self?.sendData(text)
		}
		alert.addAction(confirm)
		let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
			alert.dismissViewControllerAnimated(true, completion: nil)
		}
		alert.addAction(cancel)
		self.presentViewController(alert, animated: true, completion: nil)
	}

	private func sendData(text: String) {
		guard let service = btDiscoverySharedInstance.bleService else { return }
		service.writePosition(text)
	}
}

