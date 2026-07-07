//
//  MessagesViewController.swift
//  Travel Stickers MessagesExtension
//
//  Created by Zohaib Afzal
//

import Messages
import UIKit

final class MessagesViewController: MSStickerBrowserViewController {
    private var stickers: [MSSticker] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        stickerBrowserView.backgroundColor = .clear
        loadDestinationStickers()
    }

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        stickers.count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        stickers[index]
    }

    private func loadDestinationStickers() {
        let stickerNames = [
            "tokyo",
            "sydney",
            "rome",
            "santorini",
            "glaciernationalpark",
            "paris",
            "borabora",
            "maldives"
        ]

        stickers = stickerNames.compactMap { stickerName in
            guard let url = Bundle.main.url(forResource: stickerName, withExtension: "png") else {
                return nil
            }

            return try? MSSticker(
                contentsOfFileURL: url,
                localizedDescription: stickerName.replacingOccurrences(of: "-", with: " ")
            )
        }

        stickerBrowserView.reloadData()
    }
}
