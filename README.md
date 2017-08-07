# HIP
HLS Audio Multithreaded Player

# Descriptions
This is a app for iOS using Swift 3.x for proof of concept of downloading audio track from HLS m3u8 file using multithreaded download

# Demo
[HIP Demo](https://youtu.be/v2N6QMTp46o) 

# Features
* HTTP framework using Alamofire
* Using NSOperation and NSOperationQueue for async concurrent downloads, with max concurrent task set to 2
* M3U8 parse using my own forked version M3U8Kit, with changes I made for support M3U8 v4 where it can byte ranges download from single file, and update the MediaPlaylist info model to support offset and length of ts file parts. Download from my repo https://github.com/azanium/M3U8Paser
* Player View and Player Audio is two different components. Where Player Audio will use Streamer component to stream the HLS audio from server to local. In which the app consume the audio to play with.
* Player view drag drop and swipe all using NSLayoutConstraint with CurveEaseOut animation applied to both drag drop and swipe.
