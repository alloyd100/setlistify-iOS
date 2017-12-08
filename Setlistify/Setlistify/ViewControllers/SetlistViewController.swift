//
//  SetlistViewController.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit
import Spinner
import Kingfisher
import MediaPlayer
import SpotifyLogin

class SetlistViewController: UITableViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, MPMediaPickerControllerDelegate, UIViewControllerPreviewingDelegate {
    
    var player: SPTAudioStreamingController?
    var playingTrack: SPTTrack? {
        didSet {
            self.updateNowPlayingCenter(title: playingTrack?.name ?? "", artist: playingTrack?.artistsString() ?? "", albumURL: playingTrack?.album.largestCover.imageURL, currentTime: 0, songLength: NSNumber(value: playingTrack?.duration ?? 0.0))
            
            var rows: [IndexPath] = []
            if let track = playingTrack {
                if let ip = self.indexPathForTrack(track: track) {
                    rows.append(ip)
                }
                
            }
            if let track = oldValue {
                if let ip = self.indexPathForTrack(track: track) {
                    rows.append(ip)
                }
            }
            
            self.tableView.reloadRows(at: rows, with: UITableViewRowAnimation.automatic)
        }
    }
    var pausedTrack: SPTTrack?
    var currentPlaybackPosition: TimeInterval = TimeInterval()
    
    var similarSets: SetlistSearchResponse?
    var similarSetsCurrentPage = 1
    
    var dataSource: SetlistSearchResponse?
    var selectedSetIndex = 0
    
    var selectedSetList: Setlist?
    @IBOutlet weak var spotifyButtonContainerView: UIView!
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var bandImageHeaderView: UIImageView!
    
    @IBOutlet weak var bandNameLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var spotifyLogo: UIImageView!
    @IBOutlet weak var addSetlistButton: UIButton!
    @IBOutlet weak var addSetlistWidthConstraint: NSLayoutConstraint!

    var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSetList = dataSource?.setlist[self.selectedSetIndex]
        self.tableView.sectionFooterHeight = 40
        self.tableView.sectionHeaderHeight = 0
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        
        self.tableView.reloadData()
        setupHeader()
        
        getData()
        getSimilarSetsData()
        setupLogoInTop()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SpotifyConnectionManager.logInToPlayer(setlistVC: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.pauseTrack()
        self.stopPlaying()
    }
    
    func setupLogoInTop() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 45))
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let logo = #imageLiteral(resourceName: "setlistify_logo")
        imageView.image = logo
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.navigationItem.titleView = imageView
        
        self.gradientLayer = CAGradientLayer()
        
        gradientLayer?.frame = CGRect(x: 0, y: 0, width: 1000, height: 450)
        gradientLayer?.masksToBounds = true
        let color1 = (UIColor.clear.cgColor) as CGColor
        let color2 = (UIColor.white.cgColor) as CGColor
        gradientLayer?.colors = [color1, color2]
        
        self.gradientView.backgroundColor = .clear
        self.gradientView.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    func setupHeader() {
        spotifyButtonContainerView.roundCorners(.allCorners, radius: 20)
        
        if let images = self.selectedSetList?.artist.spotifyArtist?.images as? [SPTImage] {
            
            var topImageSize: CGFloat = 0.0
            var imageToUse: SPTImage?
            for img in images {
                if img.size.width > topImageSize {
                    topImageSize = img.size.width
                    imageToUse = img
                }
            }
            
            if let img = imageToUse {
                self.bandImageHeaderView.kf.setImage(with: img.imageURL, placeholder: UIImage(named: "gigBackground"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
        
        bandNameLabel.text = selectedSetList?.artist.name
        venueLabel.text = selectedSetList?.venue.venueFullName()
        dateLabel.text = Date.presentableDateFromDate(eventDate: selectedSetList?.eventDate ?? "01-01-1990")
        

    }
    
    func getData() {
        guard let setlist = self.selectedSetList else { return }
        SpotifyConnectionManager.addSpotifyInfoToSetlist(setlist: setlist) { (result) in
            self.selectedSetList = result
            self.tableView.reloadData()
            self.setupHeader()
        }
    }
    
    func getSimilarSetsData() {
        guard let setlist = self.selectedSetList else { return }
        SetlistConnectionManager.searchSimilarSets(with: setlist.venue, date: setlist.eventDate, pageNumber: similarSetsCurrentPage) { (response) in
        
            switch response.result {
            case .success(let data):

                if let _ = self.similarSets {
                    self.similarSets?.setlist.append(contentsOf: data.setlist)
                }
                else {
                    self.similarSets = data
                }
                
                self.tableView.reloadData()
                
            case .failure:
                
                let myalert = UIAlertController(title: "Sorry", message: "We couldn't find any setlists.", preferredStyle: UIAlertControllerStyle.alert)
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Selected")
                })
                self.present(myalert, animated: true)
            }
        }
    }
    
    func trackForIndexPath(indexPath: IndexPath) -> SPTTrack? {
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if indexPath.section < setCount {
            if let set = selectedSetList?.sets.setArray[indexPath.section] {
                let song = set.song[indexPath.row]
                return song.spotifyTrack
            }
        }

        return nil
    }
    
    func indexPathForTrack(track: SPTTrack) -> IndexPath? {
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        
        if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows {
            
            for indexPath in visibleIndexPaths {
                
                if indexPath.section < setCount {
                    if let set = selectedSetList?.sets.setArray[indexPath.section] {
                        let song = set.song[indexPath.row]
                        if track.name == (song.spotifyTrack?.name ?? "") {
                            return indexPath
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    //MARK: Actions
    @IBAction func AddSetlistToSpotifyTapped(_ sender: Any) {
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil || token == nil {
                let button = SpotifyLoginButton(viewController: self!,
                                                scopes: [.streaming,
                                                         .userReadTop,
                                                         .playlistReadPrivate,
                                                         .userLibraryRead,
                                                         .playlistModifyPublic,
                                                         .playlistModifyPrivate,
                                                         .userModifyPlaybackState,
                                                         ])
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self?.loginSuccessful),
                                                       name: .SpotifyLoginSuccessful,
                                                       object: nil)
                button.sendActions(for: .touchUpInside)
            }
            else {
                self?.addSetlist()
            }
        }

    }
    
    func addSetlist() {
        guard let setlist = self.selectedSetList else { return }
        
        //if setlist has no songs, dont create a playlist
        if setlist.sets.songCount() == 0 {
            let myalert = UIAlertController(title: "Sorry", message: "There hasn't been any songs registered to this set currently. Please go to Setlist.fm to add songs.", preferredStyle: UIAlertControllerStyle.alert)
            myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                //do something
            })
            self.present(myalert, animated: true)
            return
        }
        
        let spinner = SpinnerView.showSpinner(inButton: self.addSetlistButton)
        addSetlistButton.setTitle("", for: .normal)
        addSetlistButton.isEnabled = false
        animateAddtoSpotify {
            
            SpotifyConnectionManager.makePlaylistFor(setlist: setlist) { (success) in
                print(success)
                spinner.dismiss()
                self.animateAddtoSpotifyDone(success: success, completion: {
                    self.addSetlistButton.isEnabled = !success
                })
            }
        }
    }
    
    @objc func loginSuccessful() {
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if token != nil {
                SpotifyConnectionManager.authToken = token ?? ""
                self?.addSetlist()
            }
        }
    }
    
    func animateAddtoSpotify(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5) {
            self.spotifyLogo.alpha = 0
            completion()
        }
    }
    
    func animateAddtoSpotifyDone(success: Bool, completion: @escaping () -> Void) {
        
        addSetlistButton.setTitle(success ? "Added Setlist" : "Add Setlist To", for: .normal)
        addSetlistButton.titleLabel?.font = success ? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 18, weight: .regular)
        
        UIView.animate(withDuration: 0.5) {
            self.spotifyLogo.alpha = 1
            self.spotifyButtonContainerView.backgroundColor = success ? UIColor.setlistifyGreen : UIColor.setlistifyBlack
            self.view.layoutIfNeeded()
            completion()
        }
    }
    
    @IBAction func setlistFmLinkButtonTapped(_ sender: Any) {
        
        if let url = URL(string: self.selectedSetList?.url ?? "") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: Tableview Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let result = selectedSetList?.sets.setArray.count ?? 1
        if similarSets?.setlist.count ?? 0 > 0 {
            return result + 1
        }
        
        return result
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if section < setCount {
            if (selectedSetList?.sets.setArray[section].name.count ?? "".count) > 0 {
                return selectedSetList?.sets.setArray[section].name
            }
            else {
                if section == 0 {
                    return "Main Set"
                }
                else if section == 1 {
                    return "Encore"
                }
                else {
                    return "Encore \(section)"
                }
            }
        }
        else {
            
            if tableView.numberOfRows(inSection: section) == 1 && selectedSetList?.sets.songCount() ?? 0 == 0 {
                return "No Results"
            }
            return "Other Sets From This Gig"
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray.withAlphaComponent(0.95)
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 10, width:
            tableView.bounds.size.width - 20, height: 40))
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        //hide other sets header if setlist has songs but has no "similar sets"
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if section >= setCount {
            if similarSets?.setlist.count == 1 && selectedSetList?.sets.songCount() ?? 0 > 0 {
                return 0
            }
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = selectedSetList else { return 0 }
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if section < setCount {
            
            if selectedSetList?.sets.setArray.count ?? 0 > section {
                let set = selectedSetList?.sets.setArray[section]
                return set?.song.count ?? 0
            }
            return 0
        }
        else {
            return similarSets?.setlist.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if indexPath.section < setCount {
            let cell: SongTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongTableViewCell
            if let set = selectedSetList?.sets.setArray[indexPath.section] {
                let song = set.song[indexPath.row]
                let playingThisSong = playingTrack?.name == (song.spotifyTrack?.name ?? "")
                
                let optionalAlbumString = SpotifyConnectionManager.authToken.count > 0 ? "(Unavailable on Spotify)" : ""
                
                if let sptTrack = song.spotifyTrack {
                    
                    var albumString = optionalAlbumString
                    var url: URL?
                    if let album = sptTrack.album {
                        albumString = album.name
                        url = album.largestCover.imageURL
                    }
                    cell.populateCell(with: song.name, albumName: albumString, imageURL: url, info: song.fullInfo(), spotifySupport: true, playing: playingThisSong)
                }
                else {
                    cell.populateCell(with: song.name, albumName: optionalAlbumString, imageURL: nil, info: song.fullInfo(), spotifySupport: false, playing: false)
                }
            }

            return cell
        }
        else {
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = similarSets?.setlist[indexPath.row].artist.name
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.setlistifyCream
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if indexPath.section < setCount {
            if let set = selectedSetList?.sets.setArray[indexPath.section] {
                return set.song[indexPath.row].name.count > 0 ? 80 : 0
            }
            return 0
        }
        else {
            
            if similarSets?.setlist[indexPath.row].artist.name == self.selectedSetList?.artist.name {
                return 0
            }

            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if indexPath.section < setCount {
            if let set = selectedSetList?.sets.setArray[indexPath.section] {
                let song = set.song[indexPath.row]
                //dont turn off song if cell doesnt have a replacement track
                guard let _ = song.spotifyTrack else { return }
                guard let player = self.player else { return }
                
                var isPlaying = true
                if let state = player.playbackState {
                    isPlaying = state.isPlaying
                }

                if isPlaying {
                    
                    //if selected playing track
                    if let playingTrack = self.playingTrack {
                        if playingTrack.identifier == song.spotifyTrack?.identifier {
                            self.pauseTrack()
                        }
                        else {
                            self.playTrack(song: song)
                        }
                    }
                    else {
                        playTrack(song: song)
                    }
                }
                else {
                    
                    //NOT PLAYING
                    //if selected paused track
                    if let pausedTrack = self.pausedTrack {
                        if pausedTrack.identifier == song.spotifyTrack?.identifier {
                            self.resumeTrack()
                        }
                        else {
                            self.playTrack(song: song)
                        }
                    }
                    else {
                         self.playTrack(song: song)
                    }
                }
            }
        }
        else {
            
            self.title = ""
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetlistViewController") as! SetlistViewController
            vc.dataSource = similarSets
            vc.selectedSetIndex = indexPath.row
            vc.title = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let setCount = selectedSetList?.sets.setArray.count ?? 0
        if indexPath.section >= setCount {
            
            guard let data = similarSets else { return }
            if indexPath.row == similarSetsCurrentPage * data.itemsPerPage - 1 {
                if data.setlist.count < data.total {
                    similarSetsCurrentPage += 1
                    getSimilarSetsData()
                }
            }
        }

    }
    
    //MARK: Previewing delegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = self.tableView?.indexPathForRow(at: location) else { return nil }
        guard let cell = self.tableView?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController else { return nil }
        
        if let track = trackForIndexPath(indexPath: indexPath) {

            var url: URL?
            if let album = track.album {
                url = album.largestCover.imageURL
            }
            
            detailVC.imageurl = url
        }

        detailVC.preferredContentSize  = CGSize(width: 0.0, height: self.view.frame.width - 20)
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: Spotify Playback
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("logged in to player")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {

        if let tracks = self.selectedSetList?.sets.fullSongSpotifyIds() as? [SPTTrack] {
            for track in tracks {
                if trackUri.contains(track.identifier) {
                    self.playingTrack = track
                }
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        self.currentPlaybackPosition = position
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if !isPlaying {
            self.playingTrack = nil
        }
        else {
            self.pausedTrack = nil
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }
    
    func pauseTrack() {
        self.pausedTrack = self.playingTrack
        self.playingTrack = nil
        self.player?.setIsPlaying(false, callback: { (error) in
            if error != nil {
                print("pause failed")
            }
        })
    }
    
    func resumeTrack() {
        self.playingTrack = self.pausedTrack
        self.pausedTrack = nil
        self.player?.setIsPlaying(true, callback: { (error) in
            if error != nil {
                print("pause failed")
            }

            self.updateNowPlayingCenter(title: self.playingTrack?.name ?? "", artist: self.playingTrack?.artistsString() ?? "", albumURL: self.playingTrack?.album.largestCover.imageURL, currentTime: NSNumber(value: self.currentPlaybackPosition), songLength: NSNumber(value: self.playingTrack?.duration ?? 0.0))
        })
    }
    
    func nextTrack() {
        self.player?.skipNext({ (error) in
            if error != nil {
                print("next failed")
            }
        })
    }
    
    func previousTrack() {
        self.player?.skipPrevious({ (error) in
            if error != nil {
                print("previous failed")
            }
        })
    }
    
    func stopPlaying() {
        self.playingTrack = nil
    }
    
    func playTrack(song: Song) {
        guard let trackID = song.spotifyTrack?.identifier
            else { return }
        

        self.player?.playSpotifyURI("spotify:track:" + trackID, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("failed!")
            }
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            //queue remaining tracks
//            if let tracks = self.selectedSetList?.sets.fullSongSpotifyIds() as? [SPTTrack] {
//                var index = 0
//                for (count, track) in tracks.enumerated() {
//                    if track.identifier == song.spotifyTrack?.identifier {
//                        index = count
//                        break
//                    }
//                }
//
//                //last track, dont need to queue any
//                if index + 1 >= tracks.count {
//                    return
//                }
//
//                let totalTracks = tracks.count - 1
//                let subset = tracks[index + 1...totalTracks]
//                let queueArray : [SPTTrack] = Array(subset)
//                for (index, track) in queueArray.enumerated() {
//
//                    //hack to get around call limit spotify has
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index), execute: {
//                        self.queueTrack(track: track)
//                    })
//
//                }
//            }
        })
    }
    
    func queueTrack(track: SPTTrack) {
        guard let trackID = track.identifier
            else { return }
        self.player?.queueSpotifyURI("spotify:track:" + trackID, callback: { (error) in
            if error != nil {
                print("failed")
                return
            }
            print("queued: \(track.name)")
        })
    }
    
    func updateNowPlayingCenter(title: String, artist: String, albumURL: URL?, currentTime: NSNumber, songLength: NSNumber){
        
        var songInfo: [String : Any] = [
            
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: songLength
        ]
        
        if let url = albumURL {
            downloadImage(url: url, completion: { (image) in
                if let img = image {
                    songInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: img)
                }
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            })
        }
        else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        }
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        guard let evnt = event else { return }
        if evnt.type == .remoteControl {
            
            switch evnt.subtype {
            case .remoteControlPlay:
                self.resumeTrack()
                
            case .remoteControlPause:
                self.pauseTrack()
                
            case .remoteControlTogglePlayPause:
                (self.player?.playbackState.isPlaying ?? false) ? self.pauseTrack() : self.resumeTrack()
                
            case .remoteControlNextTrack:
                self.nextTrack()
                
            case .remoteControlPreviousTrack:
                self.previousTrack()
                
            case .remoteControlBeginSeekingBackward:
                break
                
            case .remoteControlEndSeekingBackward:
                break
                
            case .remoteControlBeginSeekingForward:
                break
                
            case .remoteControlEndSeekingForward:
                break
                
            default:
                break
            }
        }
    }
    
    //download Image code
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completion(UIImage(data: data))
            }
        }
    }
}
