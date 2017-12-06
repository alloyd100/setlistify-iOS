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

class SetlistViewController: UITableViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    var player: SPTAudioStreamingController?
    var playingTrack: Song? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
        
        SpotifyConnectionManager.logInToPlayer(setlistVC: self)
    }
    
    func setupLogoInTop() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 45))
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let logo = #imageLiteral(resourceName: "setlistify_logo")
        imageView.image = logo
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.navigationItem.titleView = imageView
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
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.frame = gradientView.bounds
        gradientLayer.masksToBounds = true
        let color1 = (UIColor.clear.cgColor) as CGColor
        let color2 = (UIColor.white.cgColor) as CGColor
        gradientLayer.colors = [color1, color2]
        
        self.gradientView.backgroundColor = .clear
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
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
    
    //MARK: Actions
    @IBAction func AddSetlistToSpotifyTapped(_ sender: Any) {
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
    
    func animateAddtoSpotify(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5) {
            self.spotifyLogo.alpha = 0
            completion()
        }
    }
    
    func animateAddtoSpotifyDone(success: Bool, completion: @escaping () -> Void) {
        
        addSetlistButton.setTitle(success ? "Added Setlist" : "Add Setlist To", for: .normal)
        addSetlistButton.titleLabel?.font = success ? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 18, weight: .regular)
        
        addSetlistButton.titleEdgeInsets.left = success ? 10 : 20
        
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
            return "Other Sets From This Gig"
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray.withAlphaComponent(0.95)
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 10, width:
            tableView.bounds.size.width, height: 40))
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
                let playingThisSong = playingTrack?.name == song.name

                cell.populateCell(with: song.name, albumName: song.spotifyTrack?.album.name ?? "-", imageURL: song.spotifyTrack?.album.largestCover.imageURL, info: song.fullInfo(), playing: playingThisSong)
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
                
                if song.name == self.playingTrack?.name {
//                    do {
//                        try self.player?.stop()
//                    }
//                    catch {
//
//                    }
                    self.playTrack(song: Song())
                    self.stopPlaying()
                }
                else {
                    self.playTrack(song: song)
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
    
    
    //MARK: Spotify Playback
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("logged in to player")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if !isPlaying {
            stopPlaying()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }
    
    func stopPlaying() {
        self.playingTrack = nil
        self.tableView.reloadData()
    }
    
    func playTrack(song: Song) {
        guard let trackID = song.spotifyTrack?.identifier
            else { return }
        self.player?.playSpotifyURI("spotify:track:" + trackID, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("failed!")
            }
            UIApplication.shared.beginReceivingRemoteControlEvents()
 //           self.updateNowPlayingCenter(title: song.name, artist: song.spotifyTrack?.artists[0].name, albumArt: nil, currentTime: 0, songLength: 3,:12, PlaybackRate: 1)
            self.playingTrack = song
        })
    }
    
//    func updateNowPlayingCenter(title: String, artist: String, albumArt: AnyObject, currentTime: NSNumber, songLength: NSNumber, PlaybackRate: Double){
//        
//        var songInfo: Dictionary <NSObject, AnyObject> = [
//            
//            MPMediaItemPropertyTitle: title,
//            MPMediaItemPropertyArtist: artist,
//            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: albumArt as! UIImage),
//            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
//            MPMediaItemPropertyPlaybackDuration: songLength,
//            MPNowPlayingInfoPropertyPlaybackRate: PlaybackRate
//        ]
//        
//        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo as [NSObject : AnyObject]
//    }

}
