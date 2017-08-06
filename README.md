# HIP
HLS Audio Multithreaded Player

# Descriptions
This is a app for iOS using Swift 3.x for proof of concept of downloading audio track from HLS m3u8 file using multithreaded download

# Features
* HTTP framework using Alamofire 4.4
* Using NSOperation and NSOperationQueue for async concurrent download, with max concurrent task set to 2
* M3U8 parse using forked version M3U8Kit, with changes I made for support v4 M3U8 where it can byte ranges download from single file, and update the MediaPlaylist info model to support offset and length of ts parts. Download from my repo https://github.com/azanium/M3U8Paser