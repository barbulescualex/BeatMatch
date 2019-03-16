//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

let button = MidiButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100), sound: Sounds.chime)
PlaygroundPage.current.liveView = button


//chime : https://www.zapsplat.com/music/gamelan-ching-finger-cymbals-shake-crescendo/
//kick : http://music.arts.uci.edu/dobrian/summeracademy2014/sounds/drums/kick1.aiff
//snare : dight310.byu.edu/media/audio/Free.../Hollow Snare 1-1647-Free-Loops.com.mp3
