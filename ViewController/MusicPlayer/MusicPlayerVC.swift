//
//  MusicPlayerVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 24/3/25.
//

/*

 */

import UIKit
import AVFoundation
import MediaPlayer
import SDWebImage

class MusicPlayerVC: BaseVC, AllPlaylistMusicDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var actor: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var minTime: UILabel!
    @IBOutlet weak var maxTime: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var replayBtn: UIButton!
    
    var streamingPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var currentIndex: Int = 0
    var musicList: [MP3File] = []
    var timeObserverToken: Any?

    // MARK: – Loop setting
    private let loopKey = "shouldLoopPlaylist"
    private var shouldLoop: Bool {
        get { UserDefaults.standard.bool(forKey: loopKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: loopKey)
            let imageName = newValue ? "replay" : "replay_in"
            replayBtn.setImage(UIImage(named: imageName), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRemoteTransportControls()
        let _ = shouldLoop
        setupPlayer(for: currentIndex)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayer()
    }

    func setupView() {
        name.font = UIFont.G_B(40)
        actor.font = UIFont.G_B(22)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        let imageName = shouldLoop ? "replay" : "replay_in"
        replayBtn.setImage(UIImage(named: imageName), for: .normal)
    }

    func setupPlayer(for index: Int) {
        guard musicList.indices.contains(index) else { return }
        stopPlayer()

        let music = musicList[index]
        name.text = music.title
        actor.text = music.artist

        var mediaURL: URL?
        if music.source == "Apple Music", let urlStr = music.localPath, let url = URL(string: urlStr) {
            mediaURL = url
        } else if let rel = music.localPath {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            mediaURL = docs.appendingPathComponent(rel)
        }

        guard let url = mediaURL else {
            print("No playable source for \(music.title)")
            return
        }

        let ext = url.pathExtension.lowercased()
        let isVideo = ["mp4", "mov", "m4v"].contains(ext)

        streamingPlayer = AVPlayer(url: url)

        if isVideo {
            img.isHidden = true
            playerLayer = AVPlayerLayer(player: streamingPlayer)
            playerLayer?.frame = contentView.bounds
            playerLayer?.videoGravity = .resizeAspect
            if let pl = playerLayer {
                contentView.layer.addSublayer(pl)
            }
        } else {
            img.isHidden = false
            if let artworkURL = music.artworkURL, let artwork = URL(string: artworkURL) {
                img.sd_setImage(with: artwork, placeholderImage: UIImage(named: "blank_big"))
            } else {
                img.image = UIImage(named: "blank_big")
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackDidFinishPlaying(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: streamingPlayer?.currentItem)
        streamingPlayer?.play()
        observeStreamingPlayerTime()
    }

    func stopPlayer() {
        streamingPlayer?.pause()
        if let token = timeObserverToken {
            streamingPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: streamingPlayer?.currentItem)
        streamingPlayer = nil

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        img.isHidden = false
    }

    @objc func trackDidFinishPlaying(_ notification: Notification) {
        if currentIndex < musicList.count - 1 {
            currentIndex += 1
            setupPlayer(for: currentIndex)
        } else if shouldLoop && musicList.count > 0 {
            currentIndex = 0
            setupPlayer(for: currentIndex)
        } else {
            playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
            print("End of playlist")
        }
    }


    func observeStreamingPlayerTime() {
        guard let player = streamingPlayer else { return }

        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration.seconds, duration.isFinite else { return }
            let currentTime = CMTimeGetSeconds(time)
            self.slider.maximumValue = Float(duration)
            self.slider.value = Float(currentTime)
            self.minTime.text = self.formatTime(currentTime)
            self.maxTime.text = self.formatTime(duration)
            updateNowPlayingInfo()
        }
    }

    func updateNowPlayingInfo() {
        guard let player = streamingPlayer, let currentItem = player.currentItem else { return }
        var nowPlayingInfo = [String: Any]()
        let music = musicList[currentIndex]
        nowPlayingInfo[MPMediaItemPropertyTitle] = music.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = music.artist

        if let artworkURL = music.artworkURL, let url = URL(string: artworkURL),
           let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in image })
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            self.streamingPlayer?.play()
            self.playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
            self.updateNowPlayingInfo()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.streamingPlayer?.pause()
            self.playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
            self.updateNowPlayingInfo()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if self.currentIndex < self.musicList.count - 1 {
                self.currentIndex += 1
                self.setupPlayer(for: self.currentIndex)
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            if self.currentIndex > 0 {
                self.currentIndex -= 1
                self.setupPlayer(for: self.currentIndex)
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    @objc func sliderValueChanged(_ slider: UISlider) {
        guard let player = streamingPlayer else { return }
        let seconds = CMTime(seconds: Double(slider.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: seconds)
    }

    // MARK: - Action Buttons

    @IBAction func playPause(_ sender: Any) {
        guard let player = streamingPlayer else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseBtn.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
        }
    }

    @IBAction func next(_ sender: Any) {
        guard currentIndex < musicList.count - 1 else { return }
        currentIndex += 1
        setupPlayer(for: currentIndex)
        playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
    }

    @IBAction func pre(_ sender: Any) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        setupPlayer(for: currentIndex)
        playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
    }

    @IBAction func replay(_ sender: Any) {
        shouldLoop.toggle()
    }
    
    @IBAction func allPlaylistMusic(_ sender: Any) {
        let listVC = AllPlaylistMusicVC()
        listVC.musicList = self.musicList
        listVC.delegate = self
        present(listVC, animated: true, completion: nil)
    }

    // MARK: - AllPlaylistMusicDelegate
    func didSelectMusic(at index: Int) {
        currentIndex = index
        setupPlayer(for: currentIndex)
        playPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        stopPlayer()
    }
}

